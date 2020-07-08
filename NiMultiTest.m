function xPrediction = NiMultiTest(filename, netName)
close all

%variables to consider: tau, startTest, lengthTest
tau = 27;
lengthTest = 2000;
errorThreshold = .15;
initLength = 200;
rowTest = 1;

%load file to analyze. Filter and normalize data
new_map = load(filename); 
data = new_map;
xfiltData = sgolayfilt(data,2,21);
xMean = mean(xfiltData);
xStd = std(xfiltData);
xStdData = (xfiltData - xMean)/xStd;

%create delta map as target output
x2Data = xfiltData (2:end);
x1Data = xfiltData(1:end-1);
dStdData = x2Data - x1Data;
dStdData = sgolayfilt(dStdData,2,21);
%dData = sgolayfilt(dData,2,21);
%dMean = mean(dData);
%dStd = std(dData);
%dStdData = (dData - dMean)/dStd;

%load and extract network from struct
net = load(netName);
fn = fieldnames(net);
net = net.(fn{1});

numIn = net.inputs{1}.size;

%data and plotting parameters
%startTest = 1000;
startTest = floor(length(xStdData)*.5);
startRowTest = startTest + (tau * (rowTest - 1));
startTrue = startRowTest - initLength + 1;

% initialize matrices
xPrediction = zeros(numIn,lengthTest - 1);
dPrediction = zeros(numIn, 1);

%create initial values of xPrediction
i = 1;
j = startTest;
while i <= numIn
    xPrediction(i,1) = xStdData(j);
    i = i + 1;
    j = j + tau;
end
i = 2;

%isolate true data to plot against
xInitTrue = xfiltData(startTrue:startRowTest);
xPresTrue = xfiltData(startRowTest:(startRowTest + lengthTest - 1));
xInitTrue = xInitTrue';
xPresTrue = xPresTrue';

%xreference plots
xInit = (1:initLength);
xPres = (initLength:initLength + lengthTest - 1);

hold on
subplot(2,1,1)
plot(xPres,xPresTrue)
pause(1)
subplot(2,1,2)
plot(xPres,dStdData(startRowTest:(startRowTest + lengthTest - 1)))
%series prediction
while i <= lengthTest
    dPrediction(:,1) = net(xPrediction(:,(i-1)));
    %rescale data
    %dPrediction = dPrediction * dStd + dMean;
    xPrediction(:,i-1) = xPrediction(:,i-1) * xStd + xMean;
    
    %add delta to real data
    xPrediction(:,i) = xPrediction(:,i-1) + dPrediction;

    subplot(2,1,1)
    hold on
    plot(xPres(i),xPrediction(rowTest,i),'.','MarkerSize',5)
    
    subplot(2,1,2)
    hold on
    plot(xPres(i),dPrediction(rowTest),'.','MarkerSize',5)
    pause(.003)
    %standardize prediction data again
    xPrediction(:,i) = (xPrediction(:,i) - xMean)/xStd;
    i = i + 1;
end

%rescale prediction data one more time
xPrediction(:,i-1) = xPrediction(:,i-1) * xStd + xMean;
xPrediction = xPrediction(rowTest,:); %isolate column of data

%calculate prediction limit of trained ANN
predictionLimit = 0;
xError = xPrediction - xPresTrue;
for i = 1:lengthTest
    if abs(xError(i)) >= errorThreshold
        predictionLimit = i;
        error = xError(i);
        disp('Prediction Limit ='), disp(predictionLimit)
        disp('Error'), disp(error)
        break
    end
end
%plot true and predict logistic map on the same graph
%subplot(2,1,1)
figure
hold on
title('True and Predicted Current')
initCurve = plot(xInit,xInitTrue,'b');
set(initCurve,'handleVisibility','off')
plot(xPres,xPresTrue,'b')
plot(xPres,xPrediction, 'r')
ylabel('Current (A)')
xlabel('Time (s)')
title('True and Predicted Current')
xline(predictionLimit + initLength,':k','LineWidth',2);
xline(initLength,'k','LineWidth',2);
legend('True map','Predicted map','Prediction Limit','Start of Prediction')
xlim([0 initLength + lengthTest])
xticks([])
xticks(initLength:200:initLength + lengthTest)
xticklabels(0:1:(lengthTest/200))
hold off

%plot the error between true and predicted
%subplot(2,1,2)
figure
hold on
plot(xError)
ylabel('Error (Predicted - Target) in Current (A)')
xlabel('Time (s)')
title('Prediction Error')
xline(predictionLimit,':k','LineWidth',2);
legend('Error','Prediction Limit')
xlim([0 lengthTest])
xticks([])
xticks(0:200:lengthTest)
xticklabels(0:1:(lengthTest/200))
hold off
    


