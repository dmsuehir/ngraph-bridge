pip install Cython pillow lxml jupyter matplotlib
pip install pycocotools

echo "Install protoc"
PROTOC_ZIP=protoc-3.3.0-linux-x86_64.zip
wget --quiet https://github.com/protocolbuffers/protobuf/releases/download/v3.3.0/$PROTOC_ZIP
unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
unzip -o $PROTOC_ZIP -d /usr/local include/*
rm -f $PROTOC_ZIP

# Protobuf Compilation
cd research
protoc object_detection/protos/*.proto --python_out=.
cd ..