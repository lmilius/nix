{ pkgs, config, ...}:

{
  environment.systemPackages = with pkgs; [
    python311
    python311Packages.paho-mqtt_2
    python311Packages.requests
    python311Packages.ruamel-yaml
    python311Packages.pytz
  ];

  # To check calendar times: 
  # systemd-analyze calendar "*-*-* *:00:00" --iterations=10
  systemd = {
    timers."img2mqtt-10min" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/10";
        Persistent = true;
      #   # OnBootSec = "1h";
      #   # OnUnitActiveSec = "1h";
      #   Unit = "img2mqtt-hourly";
      };
    };
    services."img2mqtt-10min" = {
      # script = ''
      #   /home/lmilius/workspace/py2mqtt/image_to_mqtt.sh cam_saylorville cam_i35 spc_activity mesonet_outlook mesonet_radar iowa_precip winter_roads winter_snowfall winter_midwest_snowfall winter_windchill winter_snowdepth wssi expected_snow expected_ice
      # '';
      enable = true;
      description = "Python script to send Image URLs to MQTT for Home Assistant";

      serviceConfig = {
        ExecStart = "${pkgs.python311}/bin/python image_to_mqtt.py cam_saylorville";
        Type = "oneshot";
        User = "root";
        WorkingDirectory = "/home/lmilius/workspace/py2mqtt";
      };
    };
  };
}