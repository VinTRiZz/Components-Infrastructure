#! /bin/bash

if (apt show code &> /dev/null); then
echo "Code installed! Skipping step..."
else
curl https://vscode.download.prss.microsoft.com/dbazure/download/stable/e170252f762678dec6ca2cc69aba1570769a5d39/code_1.88.1-1712771838_amd64.deb --output tmp/code.deb
apt install ./tmp/code.deb
fi
