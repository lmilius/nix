{ pkgs ? import <nixpkgs> {} }:

pkgs.python3.withPackages (ps: with ps; [
  paho-mqtt_2
  requests
  ruamel-yaml
  pytz
])