%% Naming the classifier
classifierFilename = ['Classifier_sub_0_ses_0.mat'];
pathsave = [cd ,'\mat_files\'];
SP.order = 4;   % Order of the filter
SP.band = [8 30]; % Temporal Filtering Bands
SP.Smp_Rate = 250; % Define Sampling Rate
SP.No_of_Components = 4;
%% Build the SVM classifier for CSP feature
allData = [];

X3D_ChSampTrl = data;

allData = cat(2,allData,permute(X3D_ChSampTrl,[1,3,2]));
Labels_T = Labels;

y_shuff = Labels_T; 

data_tr = permute(allData,[1,3,2]);
for ind_trial=1:size(data_tr,3)
    Pxx=bandpower(squeeze(data_tr(:,:,ind_trial))',SP.Smp_Rate,SP.band);
    x_shuff(:,ind_trial)=Pxx';
end

% iNumBags=200;
% min_leaf_size=5;
% MdlRandom = TreeBagger(iNumBags,x_shuff',y_shuff,'Method','regression','OOBVarImp','On',...
%     'MinLeafSize',min_leaf_size);
% 
% [a,b] = sort(MdlRandom.OOBPermutedVarDeltaError,'descend');
out = 1:numChn;

icode = Labels_T-1;

% ======== Apply Z-score Normalization =========
%for i = 1:size(data_tr,3)
 %   data_tr(:,:,i) = zscore(data_tr(:,:,i), 0, 2);  % normalize along time
%end
[Train_X, Train_Y,PTranspose] = fn_MEGBCI_train_CSP(data_tr(out,:,:),icode,SP);

disp('#######  Training The SVM Classsifier ##########')
Tr_SVMModel = fitcsvm(Train_X,Train_Y);
%Tr_LDA = fitcdiscr(Train_X,Train_Y);
%Tr_LogReg = fitclinear(X, Y, 'Learner', 'logistic');
%Tr_RF = TreeBagger(100, Train_X, Train_Y, 'Method', 'classification');

disp('#######  Testing The SVM Classsifier ##########')
%[Pred_Y] = predict(Tr_LDA, Train_X);
%[Pred_Y] = predict(Tr_LogReg, Train_X);
%[Pred_Y] = predict(Tr_RF, Train_X);
[Pred_Y]=predict(Tr_SVMModel,Train_X);
Training_ACC = 100*mean(Pred_Y==Train_Y);

save([pathsave classifierFilename],'out','Train_X','Train_Y','Tr_SVMModel','PTranspose','SP');
%save([pathsave classifierFilename],'out','Train_X','Train_Y','Tr_LDA','PTranspose','SP');
%save([pathsave classifierFilename],'out','Train_X','Train_Y','Tr_LogReg','PTranspose','SP');
%save([pathsave classifierFilename],'out','Train_X','Train_Y','Tr_RF','PTranspose','SP');
