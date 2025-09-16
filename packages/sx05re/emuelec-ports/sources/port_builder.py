#!/usr/bin/env python

import jinja2
import yaml

from os import environ, getcwd, path
from sys import argv

def meets_requirements(data):
    if not "requires" in data:
        # No specific requirements
        return True

    for supported_setup in data["requires"]:
        acceptable = True
        for key, value in supported_setup.items():
            if environ.get(key) != value:
                acceptable = False
                break

        if acceptable:
            return True

    return False


yaml_file = argv[1]
try:
    output_location = argv[2]
except IndexError:
    output_location = getcwd() 

templateLoader = jinja2.FileSystemLoader(searchpath=".")
templateEnv = jinja2.Environment(loader=templateLoader)
port_template = templateEnv.get_template("port.sh.j2")
gamelist_template = templateEnv.get_template("gamelist.xml.j2")

with open(yaml_file) as ports_file:
    ports = yaml.load(ports_file, Loader=yaml.SafeLoader)

supported_ports = [port for port in ports.items() if meets_requirements(port[1])]

for name, data in supported_ports:
    # Create port script
    with open(path.join(output_location, "{}.sh".format(name)), "w") as port_file:
        port_file.write(port_template.render(name=name, data=data))
        ports_file.close()

# Create gamelist.xml
with open(path.join(output_location, "gamelist.xml"), "w") as gamelist_file:
    gamelist_file.write(gamelist_template.render(games=supported_ports))
    gamelist_file.close()
