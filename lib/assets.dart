enum Images {
  logo("assets/images/logo.png"),
  error("assets/images/error.jpg"),
  empty_folder("assets/images/empty_folder.jpg");

  final String path;

  const Images(this.path);
}

enum EnvironmentalVariables {
  featureAddImage("FEATURE_ADD_IMAGE"),
  featureAddFolder("FEATURE_ADD_FOLDER"),
  featureCheckAnalytics("FEATURE_CHECK_ANALYTICS"),
  functionsUrl("FUNCTIONS_URL"),
  monitoringUrl("MONITORING_URL");

  final String variable;

  const EnvironmentalVariables(this.variable);
}
