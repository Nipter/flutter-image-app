package main
import (
    "fmt"
    "net/http"
    "log"
    "os"
    "io"
    "strconv"
    "github.com/google/uuid"
    "strings"
    "encoding/json"
    firebase "firebase.google.com/go/v4"
    "cloud.google.com/go/storage"
    "cloud.google.com/go/firestore"
    "google.golang.org/api/option"
    "context"
    "time"
    "google.golang.org/api/firebaseremoteconfig/v1"
    "google.golang.org/api/iterator"
    "gopkg.in/mail.v2"
)

func getApodImageData(endpoint string, apiKey string) ([]string, []map[string]string, error) {
    requestURL := endpoint + "?api_key=" + apiKey
    res, err := http.Get(requestURL)
    if err != nil {
        return []string{}, []map[string]string{}, err
    }

    resBody, err := io.ReadAll(res.Body)
    if err != nil {
        return []string{}, []map[string]string{}, err
    }

    var dat map[string]interface{}

    if err := json.Unmarshal(resBody, &dat); err != nil {
        return []string{}, []map[string]string{}, err
    }
    metadata := map[string]string{
        "title": dat["title"].(string),
        "description": dat["explanation"].(string),
        "media_type": dat["media_type"].(string),
        "date": dat["date"].(string),
    }

    return []string{dat["hdurl"].(string)}, []map[string]string{metadata}, nil
}


func getEPICImageData(endpoint string, imgEndpoint string, apiKey string, date time.Time) ([]string, []map[string]string, error) {
    formattedDate := date.Format(time.DateOnly) 
    requestURL := endpoint + "/date/" + formattedDate + "?api_key=" + apiKey
    res, err := http.Get(requestURL)
    if err != nil {
        return []string{}, []map[string]string{}, err
    }

    resBody, err := io.ReadAll(res.Body)
    if err != nil {
        return []string{}, []map[string]string{}, err
    }



    var dat []map[string]interface{}

    if err := json.Unmarshal(resBody, &dat); err != nil {
        return []string{}, []map[string]string{}, err
    }

    if len(dat) == 0 {
		return []string{}, []map[string]string{}, fmt.Errorf("Received an empty response")
	}

    var metadataList []map[string]string
    
    urls := []string{}

    for _, data := range dat {
        centroid, _ :=  json.Marshal(data["centroid_coordinates"])
        coords, _ :=  json.Marshal(data["coords"])
        metadata := map[string]string{
            "title": data["image"].(string),
            "description": data["caption"].(string),
            "centroid_coordinates": string(centroid),
            "coords": string(coords),
            "date": data["date"].(string),
        }
        metadataList = append(metadataList, metadata)
        url := fmt.Sprintf("%s/%s/png/%s.png", 
            imgEndpoint, strings.Replace(formattedDate, "-", "/", -1), data["image"])
        urls = append(urls, url)
    }

    return urls, metadataList, nil
}

func readImageFromUrl(url string) ([]byte, error) {
    res, err := http.Get(url)
    if err != nil {
        return nil, err
    }

    if res.StatusCode != 200 {
        return nil, fmt.Errorf("Status code is not 200, returned: %d", res.StatusCode)
    }

    resBody, err := io.ReadAll(res.Body)
    if err != nil {
        return nil, fmt.Errorf("Error while reading response body: %w", err)
    }

    return resBody, nil
}
func initializeAppDefault(ctx context.Context, config *firebase.Config, opt option.ClientOption) *firebase.App {
	app, err := firebase.NewApp(ctx, config)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	return app
}

func uploadFileFromMemory(ctx context.Context, bucket *storage.BucketHandle, img []byte, storageFilePath string) error {
    object := bucket.Object(storageFilePath)
    // Create a writer to the bucket
    writer := object.NewWriter(ctx)
    defer writer.Close()

    writer.ObjectAttrs.ContentType = "image/png"

    // Copy the file content to the writer
    if _, err := writer.Write(img); err != nil {
        return fmt.Errorf("failed to write file content: %v", err)
    }

    return nil
}

func addMetadata(ctx context.Context, clientFirestore *firestore.Client, fname []string, imgCloudId []string, metadata []map[string]string) error {
    var docs []string

    for i, name := range fname {
        docImages, _, err := clientFirestore.Collection("images").Add(ctx, map[string]interface{}{
            "createdAt": time.Now().Unix(),
            "imageCloudId":  imgCloudId[i],
            "name":  name,
            "updatedAt": time.Now().Unix(),
            "updatedBy": "server",
            "createdBy": "server",
            "metadata": metadata[i],
        })
        if err != nil {
            return err
        }
        docs = append(docs, docImages.ID)
    }

    currentTime := time.Now()

    // Define the layout for formatting
    layout := "15:04:05 02.01.2006"

    // Format the current time
    formattedTime := currentTime.Format(layout)

    _, _, err := clientFirestore.Collection("folders").Add(ctx, map[string]interface{}{
        "images":  docs,
        "updatedAt": time.Now().Unix(),
        "createdAt": time.Now().Unix(),
        "updatedBy": "server",
        "createdBy": "server",
        "name": formattedTime,
    })
    if err != nil {
        return fmt.Errorf("Failed adding folder: %v", err)
    }
    return nil
}

func fetchRemoteConfig(ctx context.Context) map[string]firebaseremoteconfig.RemoteConfigParameter {
    opt := option.WithCredentialsFile("zaliczenie-pl-kl-firebase-adminsdk-7mrmr-4e92b1d159.json")
    optScope := option.WithScopes("https://www.googleapis.com/auth/firebase.remoteconfig")
    firebaseremoteconfigService, err := firebaseremoteconfig.NewService(ctx, opt, optScope)
    if err != nil {
        log.Fatalf("Failed getting remote config service: %v", err)
    }

    conf, err := firebaseremoteconfigService.Projects.GetRemoteConfig("projects/zaliczenie-pl-kl").Do()
    if err != nil {
        log.Fatalf("Failed getting remote config: %v", err)
    }
    return conf.Parameters
}

func batchUpload(ctx context.Context, app *firebase.App, urls []string, metadataList []map[string]string, password string, email string) {
    client, err := app.Storage(ctx)

    if err != nil {
        log.Fatalln(err)
    }

    bucket, err := client.DefaultBucket()
    if err != nil {
        log.Fatalln(err)
    }
    clientFirestore, err := app.Firestore(ctx)
    if err != nil {
        log.Fatalln(err)
    }

    defer clientFirestore.Close()

    var  imgNames []string
    var  cloudImgNames []string
    for _, url := range urls {

        img, err := readImageFromUrl(url)
        if err != nil {
            message := fmt.Sprintf("Failed to fetch image: %w\n", err)
            log.Println(message)
            sendFailureNotification(ctx, app, password, email, err)
        }

        splittedUrl := strings.Split(url, "/")
        imgName := splittedUrl[len(splittedUrl) - 1]
        cloudImgName := "images/" + uuid.NewString() + ".png"

        err = uploadFileFromMemory(ctx, bucket, img, cloudImgName)
        if err != nil {
            message := fmt.Sprintf("Failed to upload image to bucket: %w\n", err)
            log.Println(message)
            sendFailureNotification(ctx, app, password, email, err)
            // sendErrorNotification(messagingClient, ctx, err)
        }
        imgNames = append(imgNames, imgName)
        cloudImgNames = append(cloudImgNames, cloudImgName)
        
    }
    addMetadata(ctx, clientFirestore, imgNames, cloudImgNames, metadataList)
    if err != nil {
        message := fmt.Sprintf("Failed to add metadata image: %w\n", err)
        log.Println(message)
        sendFailureNotification(ctx, app, password, email, err)
        // sendErrorNotification(messagingClient, ctx, err)
    } else {
        sendSuccessNotification(ctx, app,  password, email)
    }
}
func fetchAdminUsersEmail(ctx context.Context, app *firebase.App) ([]string, error) {
    client, err := app.Firestore(ctx)
    if err != nil {
        log.Fatalln(err)
    }
    query := client.Collection("users").Where("roles", "array-contains", "Admin")

    iter := query.Documents(ctx)

    emails := []string{}
    for {
        doc, err := iter.Next()
        if err == iterator.Done {
            break
        }
        if err != nil {
            return []string{}, err
        }

        emails = append(emails, doc.Data()["email"].(string))
    }
    return emails, nil
}

func sendEmail(password string, from string, to string, subject string, body string) error {

	smtpHost := "smtp.poczta.onet.pl"
	smtpPort := 465

	message := mail.NewMessage()
	message.SetHeader("From", from)
	message.SetHeader("To", to)
	message.SetHeader("Subject", subject)
	message.SetBody("text/plain", body)

	dialer := mail.NewDialer(smtpHost, smtpPort, from, password)

	if err := dialer.DialAndSend(message); err != nil {
		return err
	}

	return nil
}


func sendSuccessNotification(ctx context.Context, app *firebase.App,  password string, email string) {
    emails, err := fetchAdminUsersEmail(ctx, app)
    if err != nil {
        log.Println(err)
    }
        
    for _, e := range emails {
        err = sendEmail(password, email, e, "Successful upload", "Batch image upload finished successfully!") 
        if err != nil {
            log.Println(err)
        }
    }
}

func sendFailureNotification(ctx context.Context, app *firebase.App,  password string, email string, err error) {
    emails, err := fetchAdminUsersEmail(ctx, app)
    if err != nil {
        log.Println(err)
    }
        
    for _, e := range emails {
        body :=  fmt.Sprintf("Batch image upload finished with a failure! Here is the error\n%w", err)
        err = sendEmail(password, email, e, "Failed upload", body) 
        if err != nil {
            log.Println(err)
        }
    }
}

func main() {
    ctx := context.Background()
    remoteConfig := fetchRemoteConfig(ctx)
    apodEndpoint := remoteConfig["APOD_ENDPOINT"].DefaultValue.Value
    epicEndpoint := remoteConfig["EPIC_ENDPOINT"].DefaultValue.Value
    epicImageEndpoint := remoteConfig["EPIC_IMAGE_ENDPOINT"].DefaultValue.Value
    notificationEmail := remoteConfig["NOTIFICATION_EMAIL"].DefaultValue.Value
    notificationPassword := remoteConfig["NOTIFICATION_PASSWORD"].DefaultValue.Value
    nasaKey := remoteConfig["NASA_API_KEY"].DefaultValue.Value

    config := &firebase.Config{
    	StorageBucket: "zaliczenie-pl-kl.firebasestorage.app",
    	ProjectID: "zaliczenie-pl-kl",
    }

    app := initializeAppDefault(ctx, config, nil)

    
    log.Print("starting server...")

	http.HandleFunc("/batch", func(w http.ResponseWriter, r *http.Request) {
        params := r.URL.Query()
        paramType := params.Get("type")

        threeDaysAgo := time.Now().AddDate(0, 0, -3)
        var urls []string
        var metadataList []map[string]string
        var err error
        if paramType == "epic" {
            urls, metadataList, err = getEPICImageData(epicEndpoint, epicImageEndpoint, nasaKey, threeDaysAgo)
            if err != nil {
                message := fmt.Sprintf("Failed to fetch EPIC data: %w\n", err)
                log.Println(message)
                sendFailureNotification(ctx, app, notificationPassword, notificationEmail, err)
            }
        } else {
            urls, metadataList, err = getApodImageData(apodEndpoint,nasaKey)
            if err != nil {
                message := fmt.Sprintf("Failed to fetch APOD data: %w\n", err)
                log.Println(message)
                sendFailureNotification(ctx, app, notificationPassword, notificationEmail, err)
            }
        }
        paramLimit := params.Get("limit")
        var limit int 
        limit, err = strconv.Atoi(paramLimit)
        if  err != nil {
            limit = 1
        } else {
           if limit > len(urls) {
                limit = len(urls)
            }
        }

        batchUpload(ctx, app, urls[:limit], metadataList[:limit], notificationPassword, notificationEmail)
    })

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}


	// Start HTTP server.
	log.Printf("listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

