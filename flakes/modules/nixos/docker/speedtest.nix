{
  speedtest = {
    image = "linuxserver/librespeed:latest";
    environment = {
      MODE = "standalone";
    };
    ports = [
      "8080:80"
    ];
  };
}
