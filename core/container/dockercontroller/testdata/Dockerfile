FROM golang:1.13.4
RUN go get github.com/hyperledger/fabric/integration/chaincode/simple/...
RUN go build -o samplecc github.com/hyperledger/fabric/integration/chaincode/simple/cmd
ENTRYPOINT ["./samplecc"]