function net = NiTrainDelay(filename, netName)
close all

%variables to consider: hiddenNetworks,
%fracTrain, numIn,startTest,lengthTest
%set training data parameters
numHid = 15;
trainFunc = 'trainbr';
minGrad = 1e-7;
numIn = 5;
tau = 27;
fracTrain = 1/4;  %fraction of data being used to train
startTrain = 1;

%load file to analyze. Filter and normalize data
new_map = load(filename); 
data = new_map;
xfiltData = sgolayfilt(data,2,21);
xStdData = (xfiltData - mean(xfiltData))/std(xfiltData);

%data defining parameters
endTrain = floor(length(xStdData)*fracTrain);
dataLength = endTrain - startTrain - numIn; %dataLength is always 1 smaller than true data length

%create delta map as target output
x2Data = xfiltData (2:end);
x1Data = xfiltData(1:end-1);
dStdData = x2Data - x1Data;
dStdFiltData = sgolayfilt(dStdData,2,21);
%dStdData = (dData - mean(dData))/std(dData);

% initialize matrices
xInput = zeros(numIn,endTrain - numIn - startTrain + 1);
dOutput = zeros(numIn,endTrain - numIn - startTrain + 1);

j = startTrain;
%prepare inputs and outputs
for i = 1:numIn
    xInput(i,:) = xStdData((j):(j + dataLength),:);
    dOutput(i,:) = dStdData((j):(j + dataLength),:);
    j = j + tau;
end
    
%initialize ANN
net = fitnet(numHid, trainFunc);
net.trainParam.min_grad = minGrad;

%train
net = train(net,xInput,dOutput);

%save the network
save(netName,'net');