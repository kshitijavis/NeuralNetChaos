function NiTestDelay(filename, netName, plotTitle)
close all

%variables to consider: tau, startTest, lengthTest
tau = 27;
testLength= 500*200;
rowTest = 2;

%load file to analyze. Filter and normalize data
new_map = load(filename); 
data = new_map;
xfiltData = sgolayfilt(data,2,25);
xStdData = (xfiltData - mean(xfiltData))/std(xfiltData);

%create delta map as target output
x2Data = xfiltData (2:end);
x1Data = xfiltData(1:end-1);
dStdData = x2Data - x1Data;
%dStdData = (dData - mean(dData))/std(dData);

%load and extract network from struct
net = load(netName);
fn = fieldnames(net);
net = net.(fn{1});

numIn = net.inputs{1}.size;

%data defining parameters
startTest = floor(length(xStdData)*.57);

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

%rescale data
xInput = xInput * std(xfiltData) + mean(xfiltData);
%dOutput = dOutput * std(dData) + mean(dData);
%dPrediction = dPrediction * std(dData) + mean(dData);

dOutput = dOutput(rowTest,:);
dPrediction = dPrediction(rowTest,:);
%plots

%plot both maps on same graph
% %subplot(2,2,1)
% hold on
% plot(dOutput)
% plot(dPrediction)
% title('Predicted and True Current')
% legend('Predict','True')

%plot the testing logistic map
subplot(1,2,1)
%figure
plot(dPrediction - dOutput,'.','MarkerSize',.02)
ylabel('Error (Predicted - Target) in Current (A)')
xlabel('Time (s)')
title('Error')
xlim([0 testLength])
xticks([])
xticks(0:10000:testLength)
xticklabels(0:50:(testLength/200))
hold off


% %plot actual vs predicted output
subplot(1,2,2)
%figure
plot(dOutput,dPrediction,'.','MarkerSize',.02); 
xlabel('Target Current (A)')
ylabel('Network Predicted Current (A)')
title('Performance Scatterplot')

sgtitle(plotTitle)

%performance
r = corrcoef(dOutput,dPrediction);
r = r(2)

MSE = immse(dOutput,dPrediction)