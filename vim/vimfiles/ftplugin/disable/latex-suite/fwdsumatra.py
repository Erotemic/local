#!/usr/bin/python

# Part of Latex-Suite
#
# Copyright: Julien Cornebise
# Date: February 20, 2009
# Description:
#   This file calls ForwardSearch DDE function of SumatraPDF

import sys
import win32ui
import dde

# Set to 0 to prevent SumatraPDF from raising, to 1 to raise it
raiseWindow = 1

USAGE_TEXT = """
Usage: fwdsumatra.py <pdf_file> <source_file> <line_number>
"""

def usage():
    print USAGE_TEXT
    sys.exit(-1)

def main(pdf,tex,line):
    # Convert backslashes to slashes, for Unix-style calling from vimlatex
    pdf = pdf.replace("/", "\\")
    # Connect to SumatraPDF
    server = dde.CreateServer()
    server.Create("LatexSuite")
    conversation = dde.CreateConversation(server)
    conversation.ConnectTo("SUMATRA", "control")
    # Build the DDE call
    execString='[ForwardSearch("'+pdf+'","'+tex+'",'+line+',0,0,'+str(raiseWindow)+')'
    # Call !
    conversation.Exec(execString)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        usage() 

    main(sys.argv[1],sys.argv[2],sys.argv[3])
