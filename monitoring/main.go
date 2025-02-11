package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "encoding/json"
    "context"
    "time"

    "cloud.google.com/go/monitoring/apiv3/v2"
    "cloud.google.com/go/monitoring/apiv3/v2/monitoringpb"
    "google.golang.org/api/iterator"
    "google.golang.org/protobuf/types/known/timestamppb"
    "github.com/rs/cors"

)


func collectMetrics(w http.ResponseWriter, r *http.Request) {
    ctx := context.Background()

    client, err := monitoring.NewMetricClient(ctx)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)  
        return 
    }
    defer client.Close()

    // Sets your Google Cloud Platform project ID.
	projectID := "zaliczenie-pl-kl"

    endTime := time.Now()
    startTime := endTime.Add(-24 * 7 * time.Hour)

    filterType := r.URL.Query().Get("filterType")
    filter := fmt.Sprintf(`metric.type="%s"`, filterType)
    req := &monitoringpb.ListTimeSeriesRequest{
        Name:   fmt.Sprintf("projects/%s", projectID),
        Filter: filter,
        Interval: &monitoringpb.TimeInterval{
            EndTime:   timestamppb.New(endTime),
            StartTime: timestamppb.New(startTime),
        },
        View: monitoringpb.ListTimeSeriesRequest_FULL,
    }

	it := client.ListTimeSeries(ctx, req)

    // Call the API
    ret := []*monitoringpb.Point{}
    for {
		resp, err := it.Next()
        fmt.Println(resp)
		if err == iterator.Done {
			break
		}
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)  
            return 
        }
        for _, p := range resp.Points {
            ret = append(ret, p)
        }

	}
    jsonResp, err := json.Marshal(ret)

    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)  
        return 
    }
    w.Write(jsonResp)
}



func main() {
    // Create a new CORS middleware instance
    c := cors.New(cors.Options{
        AllowedOrigins: []string{"*"},                                // All origins
        AllowedMethods: []string{"GET", "POST", "PUT", "DELETE"},    // Allowed methods
        AllowedHeaders: []string{"*"},                               // All headers
        AllowCredentials: true,                                      // Allow cookies
    })

    // Your handler
    mux := http.NewServeMux()
    mux.HandleFunc("/monitoring", collectMetrics)

    // Wrap your handler with the CORS middleware
    handler := c.Handler(mux)


    log.Print("starting server...")
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}


	// Start HTTP server.
	log.Printf("listening on port %s", port)
	if err := http.ListenAndServe(":"+port, handler); err != nil {
		log.Fatal(err)
	}
}

