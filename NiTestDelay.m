function NiTestDelay(sourceFile, netName)
close all

%path to access source file and network
sourceFile = fullfile(pwd, 'Network Chaos Data', sourceFile);
netName = fullfile(pwd, 'Saved Series Nets', netName);

%load file to analyze. Filter and normalize data
newMap = load(sourceFile); 
xfiltData = sgolayfilt(newMap,2,25);
xStdData = (xfiltData - mean(xfiltData))/std(xfiltData);

%load and extract network from struct
net = load(netName);
fn = fieldnames(net);
net = net.(fn{1});

numIn = net.inputs{1}.size;

%variables to consider: tau, startTest, lengthTest
tau = 27;
random = rand / 2;
startTest = floor(length(xStdData)*random);
rowTest = 2;

%determine length of test
[~, locs] = findpeaks(xStdData, 'MinPeakDistance', 70);
numCycles = 30;
%testLength = length(xStdData) - startTest - (numIn * tau);
testLength = numCycles * (locs(2) - locs(1));

%create delta map as target output
x2Data = xfiltData (2:end);
x1Data = xfiltData(1:end-1);
dStdData = x2Data - x1Data;

% initialize matrices
xInput = zeros(numIn,testLength + 1);
dOutput = zeros(numIn,testLength + 1);

j = startTest;

%prepare inputs and outputs
for i = 1:numIn
    xInput(i,:) = xStdData((j):(j + testLength),:);
    dOutput(i,:) = dStdData((j):(j + testLength),:);
    j = j + tau;
end
%use network to make prediction
dPrediction = net(xInput);

dOutput = dOutput(rowTest,:);
dPrediction = dPrediction(rowTest,:);

%plots
%plot both maps on same graph
subplot(2,2,[3,4])
hold on
plot(dOutput)
plot(dPrediction)
title('Predicted and True Current')
legend('Predicted','True')
xlabel('Time (s)')
xlim([0 testLength])

%plot error
subplot(2,2,1)
%figure
plot(dPrediction - dOutput,'.','MarkerSize',.02)
ylabel('Error (Predicted - Target) in Current (A)')
xlabel('Time (s)')
title('Error')
xlim([0 testLength])
% xticks(0:10000:testLength)
% xticklabels(0:50:(testLength/200))
hold off


% %plot actual vs predicted output
subplot(2,2,2)
%figure
plot(dOutput,dPrediction,'.','MarkerSize',.02); 
xlabel('Target Current (A)')
ylabel('Network Predicted Current (A)')
title('Performance Scatterplot')

sgtitle('Network Performance')

%performance
r = corrcoef(dOutput,dPrediction);
r = r(2)
MSE = immse(dOutput,dPrediction)