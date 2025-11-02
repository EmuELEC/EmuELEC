import argparse
import json
import xml.etree.ElementTree as ET
from xml.dom import minidom

def json_to_es_xml(json_file, output_file, sort_key=None):
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    systems = data.get('systems', [])

    if sort_key:
        systems.sort(key=lambda s: (s.get(sort_key) or s.get('name', '')).lower())

    root = ET.Element('systemList')

    for sys in systems:
        system_el = ET.SubElement(root, 'system')

        for key in ['name', 'fullname', 'manufacturer', 'release', 'hardware', 'path', 'platform', 'theme']:
                if key in sys:
                    ET.SubElement(system_el, key).text = str(sys[key])
                
            # Handle command separately to allow "default" shorthand
        if 'command' in sys:
            if sys['command'] == "default":
                command_value = 'emuelecRunEmu.sh %ROM% -P%SYSTEM% --core=%CORE% --emulator=%EMULATOR% --controllers="%CONTROLLERSCONFIG%"'
            else:
                command_value = sys['command']
            ET.SubElement(system_el, 'command').text = command_value

        if 'extensions' in sys:
            ext_set = set()
            for ext in sys['extensions']:
                ext_set.add(ext.lower())
                ext_set.add(ext.upper())
            ET.SubElement(system_el, 'extension').text = ' '.join(sorted(ext_set, key=str.lower))

        if 'emulators' in sys and sys['emulators']:
            emulators_el = ET.SubElement(system_el, 'emulators')
            default_set = False

            for emulator in sys['emulators']:
                emu_el = ET.SubElement(emulators_el, 'emulator', {'name': emulator['name']})
                cores_el = ET.SubElement(emu_el, 'cores')

                for core in emulator.get('cores', []):
                    core_attrs = {}

                    # Handle default core
                    if core.get('default', False):
                        if not default_set:
                            core_attrs['default'] = 'true'
                            default_set = True
                        else:
                            print(
                                f"Warning: Multiple default cores found in system '{sys.get('name')}'. "
                                f"Ignoring '{core['name']}' in emulator '{emulator['name']}'"
                            )

                    # Handle incompatible extensions
                    if 'incompatible' in core:
                        if isinstance(core['incompatible'], list):
                            core_attrs['incompatible_extensions'] = ' '.join(core['incompatible'])
                        else:
                            print(f"'incompatible' should be a list in core '{core['name']}'")

                    ET.SubElement(cores_el, 'core', core_attrs).text = core['name']

    # Pretty-print the XML
    xml_str = ET.tostring(root, encoding='utf-8')
    pretty_xml = minidom.parseString(xml_str).toprettyxml(indent="    ")

    # Fix declaration and insert comment
    lines = pretty_xml.splitlines()
    lines[0] = '<?xml version="1.0" encoding="UTF-8"?>'

    comment = ('<!-- This is the EmulationStation Systems configuration file.\n'
               'All systems must be contained within the <systemList> tag.\n'
			   'This file will be replaced on any new update of EmuELEC-->')

    final_lines = [lines[0], comment] + lines[1:]
    final_xml = '\n'.join(final_lines) + '\n'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(final_xml)

    print(f"JSON to EmulationStation es_systems written to {output_file}")


def es_xml_to_json(xml_file, output_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    systems = []

    for system_el in root.findall('system'):
        system = {}

        for key in ['name', 'fullname', 'manufacturer', 'release', 'hardware', 'path', 'platform', 'theme', 'command']:
            el = system_el.find(key)
            if el is not None and el.text:
                system[key] = el.text.strip()

        ext_el = system_el.find('extension')
        if ext_el is not None and ext_el.text:
            raw_exts = ext_el.text.strip().split()
            # Deduplicate and keep only lowercase
            lower_exts = sorted(set(ext.lower() for ext in raw_exts))
            system['extensions'] = lower_exts


        emulators = []
        default_set = False
        emulators_el = system_el.find('emulators')
        if emulators_el is not None:
            for emulator_el in emulators_el.findall('emulator'):
                emulator = {'name': emulator_el.attrib.get('name'), 'cores': []}
                cores_el = emulator_el.find('cores')
                if cores_el is not None:
                    for core_el in cores_el.findall('core'):
                        core_name = core_el.text.strip()
                        core_obj = {'name': core_name}

                        if core_el.attrib.get('default') == 'true':
                            if not default_set:
                                core_obj['default'] = True
                                default_set = True
                            else:
                                print(
                                    f"Warning: Multiple default cores in system '{system.get('name')}', "
                                    f"ignoring default on core '{core_name}' in emulator '{emulator['name']}'"
                                )

                        # Handle incompatible extensions
                        incompat = core_el.attrib.get('incompatible_extensions')
                        if incompat:
                            core_obj['incompatible'] = incompat.split()

                        emulator['cores'].append(core_obj)
                emulators.append(emulator)

        if emulators:
            system['emulators'] = emulators

        systems.append(system)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({'systems': systems}, f, indent=2)

    print(f"EmulationStation es_systems to JSON written to {output_file}")


def main():
    parser = argparse.ArgumentParser(description="Convert between JSON and EmulationStation es_systems.cfg.")
    parser.add_argument('-r', '--reverse', action='store_true', help="Convert from EmulationStation es_systems to JSON (default is JSON to EmulationStation es_systems)")
    parser.add_argument('-i', '--input', help="Input file path")
    parser.add_argument('-b', '--order-by', help="Sort systems by this field (only used in JSON to EmulationStation es_systems)")
    parser.add_argument('-o', '--output', help="Output file path")

    args = parser.parse_args()

    if args.reverse:
        input_file = args.input or 'es_systems.cfg'
        output_file = args.output or 'es_systems.json'
        es_xml_to_json(input_file, output_file)
    else:
        input_file = args.input or 'es_systems.json'
        output_file = args.output or 'es_systems.cfg'
        json_to_es_xml(input_file, output_file, sort_key=args.order_by)

if __name__ == "__main__":
    main()
