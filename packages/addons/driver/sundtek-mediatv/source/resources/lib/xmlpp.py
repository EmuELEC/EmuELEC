"""Pretty print an XML document.

LICENCE:
Copyright (c) 2008, Fredrik Ekholdt
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

* Neither the name of Fredrik Ekholdt nor the names of its contributors may be used to 
endorse or promote products derived from this software without specific prior 
written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE."""

import sys as _sys
import re as _re

def _usage(this_file):
    return """SYNOPSIS: pretty print an XML document
USAGE: python %s <filename> \n""" % this_file

def _pprint_line(indent_level, line, width=100, output=_sys.stdout, ignore_contents = False):
    if line.strip():
        start = ""
        number_chars = 0
        for l in range(indent_level):
            start = start + " "
            number_chars = number_chars + 1
        if not ignore_contents:
            try:
                elem_start = _re.findall("(\<\W{0,1}\w+:\w+) ?", line)[0]
                elem_finished = _re.findall("([?|\]\]/|\-\-]*\>)", line)[0] 
                #should not have *
                attrs = _re.findall("(\S*?\=\".*?\")", line)
                output.write(start + elem_start)
                number_chars = len(start + elem_start)
                for attr in attrs:
                    if (attrs.index(attr) + 1) == len(attrs):
                        number_chars = number_chars + len(elem_finished)
                    if (number_chars + len(attr) + 1) > width:
                        output.write("\n")
                        for i in range(len(start + elem_start) + 1):
                            output.write(" ")
                        number_chars = len(start + elem_start) + 1 
                    else:
                        output.write(" ")
                        number_chars = number_chars + 1
                    output.write(attr)
                    number_chars = number_chars + len(attr)
                output.write(elem_finished + "\n")
            except IndexError:
                #give up pretty print this line
                output.write(start + line + "\n")
        else:
            output.write(start + line + "\n")
                

def _pprint_elem_content(indent_level, line, output=_sys.stdout):
    if line.strip():
        for l in range(indent_level):
            output.write(" ")
        output.write(line + "\n")

def _get_next_elem(data):
    start_pos = data.find("<")
    end_pos = data.find(">") + 1
    retval = data[start_pos:end_pos]
    stopper = retval.rfind("/")
    ignore_contents = False
    if stopper < retval.rfind("\""):
        stopper = -1
    single = (stopper > -1 and ((retval.find(">") - stopper) < (stopper - retval.find("<"))))

    ignore_excl = retval.find("<!") > -1
    ignore_question =  retval.find("<?") > -1

    if ignore_excl:
        ignore_contents = True
        cdata = retval.find("<![CDATA[") > -1
        if cdata:
            end_pos = data.find("]]>")
            if end_pos > -1:
                end_pos = end_pos + len("]]>")
                stopper = end_pos
        else:
            end_pos = data.find("-->")
            if end_pos > -1:
                end_pos = end_pos + len("-->")
                stopper = end_pos
        retval = data[start_pos:end_pos]

    elif ignore_question:
        end_pos = data.find("?>") + len("?>")
    ignore = ignore_excl or ignore_question
    
    no_indent = ignore or single

    
    return start_pos, \
           end_pos, \
           stopper > -1, \
           no_indent, \
           ignore_contents

def get_pprint(xml, indent=4, width=80):
    """Returns the pretty printed xml """
    class out:
        output = ""

        def write(self, string): 
            self.output += string
    out = out()
    pprint(xml, output=out, indent=indent, width=width)
    


    return out.output


def pprint(xml, output=_sys.stdout, indent=4, width=80):
    """Pretty print xml. 
    Use output to select output stream. Default is sys.stdout
    Use indent to select indentation level. Default is 4   """
    data = xml
    indent_level = 0
    start_pos, end_pos, is_stop, no_indent, ignore_contents  = _get_next_elem(data)
    while ((start_pos > -1 and end_pos > -1)):
        _pprint_elem_content(indent_level, data[:start_pos].strip(), 
                             output=output)
        data = data[start_pos:]
        if is_stop and not no_indent:
            indent_level = indent_level - indent
        _pprint_line(indent_level, 
                     data[:end_pos - start_pos], 
                     width=width,
                     output=output,
                     ignore_contents=ignore_contents)
        data = data[end_pos - start_pos:]
        if not is_stop and not no_indent :
            indent_level = indent_level + indent

        if not data:
            break
        else:
            start_pos, end_pos, is_stop, no_indent, ignore_contents  = _get_next_elem(data)
    

if __name__ == "__main__":
    if "-h" in _sys.argv or "--help" in _sys.argv:
        _sys.stderr.write(_usage(_sys.argv[0]))
        _sys.exit(1)
    if len(_sys.argv) < 2:
        _sys.stderr.write(_usage(_sys.argv[0]))
        _sys.exit(1)
    else:
        filename = _sys.argv[1]
        fh = open(filename)

    pprint(fh.read(), output=_sys.stdout, indent=4, width=80)
