{
  codeserver = {
    image = "lscr.io/linuxserver/code-server:latest";
    environment = {
      PUID = "1000";
      PGID = "1000";
      DEFAULT_WORKSPACE = "/config/workspace";
    };
    volumes = [
      "/home/lmilius/code-server:/config"
    ];
    ports = [
      "443:8443"
    ];
  };
}