function NiTrainandTest(filename,netName)
%{
Trains fitnet neural network to predict data and subsequently tests network
performance
%}

NiTrainDelay(filename,netName)
NiMultiTest(filename,netName)