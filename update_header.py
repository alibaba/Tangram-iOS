# -*- coding:utf-8 -*- 
import re
import sys,os

def updateHeader(DIR, PROJ):
    for path in os.listdir(DIR):
        fullPath = os.path.join(DIR, path)
        if os.path.isdir(fullPath):
            if path != "Pods":
                updateHeader(fullPath, PROJ)
        elif os.path.isfile(fullPath):
            if path.lower().endswith('.m') or path.lower().endswith('.h'):
                print('Updating: %s' % (path))
                codeFile = open(fullPath, 'r+')
                content = codeFile.read()
                content = re.sub('^(//[^\n]*\n)+//(?P<smile>[^\n]*)\n',
                                 '//\n' +
                                 '//  ' + path + '\n' +
                                 '//  ' + PROJ + '\n' +
                                 '//\n' +
                                 '//  Copyright (c) 2017-2018 Alibaba. All rights reserved.\n' +
                                 '//' + '\g<smile>' + '\n',
                                 content)
                codeFile.seek(0)
                codeFile.write(content)
                codeFile.truncate()
                codeFile.close()

updateHeader(os.path.join(sys.path[0], 'Tangram'), 'Tangram')
updateHeader(os.path.join(sys.path[0], 'TangramDemo'), 'TangramDemo')
# updateHeader(os.path.join(sys.path[0], 'TangramTest'), 'TangramTest')
print('Header updating is done.')

