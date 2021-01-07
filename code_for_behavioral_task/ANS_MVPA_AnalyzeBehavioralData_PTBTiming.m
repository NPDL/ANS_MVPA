close all
clear all

data_out{1,1}='Sub';
data_out{1,2}='Run';
data_out{1,3}='# Trials Collected in Run';
data_out{1,4}='# No Response Trials';
data_out{1,5}='# Correct Trials';
data_out{1,6}='# Incorrect Trials';
data_out{1,7}='% Correct';
data_out{1,8}='4 Trials';
data_out{1,9}='8 Trials';
data_out{1,10}='16 Trials';
data_out{1,11}='32 Trials';
data_out{1,12}='%Correct 4v8';
data_out{1,13}='%Correct 8v16';
data_out{1,14}='%Correct 16v32';

path_exp='/Users/Shipra/Documents/Experiments/ANS_fMRI_MVPA/ANS_fMRI_MVPA_';
path_data=strcat(path_exp,'Results/');
% subs={...
%     'ANS_MVPA_CB_01',...
%     'ANS_MVPA_CB_02',...
%     'ANS_MVPA_CB_04',...
%     'ANS_MVPA_CB_05',...
%     'ANS_MVPA_CB_06',...
%     'ANS_MVPA_CB_07',...
%     'ANS_MVPA_CB_08',...
%     'ANS_MVPA_CB_09',...
%     'ANS_MVPA_CB_10',...
%     'ANS_MVPA_CB_11',...
%     'ANS_MVPA_CB_12',...
%     'ANS_MVPA_CB_13',...
%     'ANS_MVPA_CB_14',...
%     'ANS_MVPA_CB_15',...
%     'ANS_MVPA_CB_16',...
%     'ANS_MVPA_CB_17'};

subs={...
    'ANS_MVPA_CB_01',...
    'ANS_MVPA_CB_02',...
    'ANS_MVPA_CB_04',...
    'ANS_MVPA_CB_05',...
    'ANS_MVPA_CB_06',...
    'ANS_MVPA_CB_07',...
    'ANS_MVPA_CB_08',...
    'ANS_MVPA_CB_09',...
    'ANS_MVPA_CB_10',...
    'ANS_MVPA_CB_11',...
    'ANS_MVPA_CB_12',...
    'ANS_MVPA_CB_13',...
    'ANS_MVPA_CB_14',...
    'ANS_MVPA_CB_15',...
    'ANS_MVPA_CB_16',...
    'ANS_MVPA_CB_17',...
    'ANS_MVPA_CB_18'...
    'ANS_MVPA_S_01',...
    'ANS_MVPA_S_02',...
    'ANS_MVPA_S_03',...
    'ANS_MVPA_S_04',...
    'ANS_MVPA_S_05',...
    'ANS_MVPA_S_07',...
    'ANS_MVPA_S_08',...
    'ANS_MVPA_S_09',...
    'ANS_MVPA_S_10',...
    'ANS_MVPA_S_11',...
    'ANS_MVPA_S_12',...
    'ANS_MVPA_S_13',...
    'ANS_MVPA_S_15',...
    'ANS_MVPA_S_16',...
    'ANS_MVPA_S_17',...
    'ANS_MVPA_S_18',...
    'ANS_MVPA_S_19',...
    'ANS_MVPA_S_20',...
    'ANS_MVPA_S_21',...
    'ANS_MVPA_S_22',...
    'ANS_MVPA_S_23',...
    'ANS_MVPA_S_25',...
    'ANS_MVPA_S_26',...
    'ANS_MVPA_S_27',...
    'ANS_MVPA_S_28',...
    'ANS_MVPA_S_29'};

nums=[4,8,16,32];

cntr_data_out=0;
sub_idx=0;
for sub_idx=1:length(subs); %for each subject
    
    path_data_sub=strcat(path_data,subs{sub_idx},'/');
    
    dirfilest = dir([path_data_sub,'*.mat']);

    a=0;
    i=0;
    for i=1:size(dirfilest);
        if strcmp(dirfilest(i).name,'.')==0 &&  strcmp(dirfilest(i).name,'..')==0 &&  strcmp(dirfilest(i).name,'.DS_Store')==0;
            if strcmp('Practice',dirfilest(i).name)==0;
                a=a+1;
                dirfiles{sub_idx}{a} = cellstr(dirfilest(i).name);
                fn_data{a}=char(strcat(path_data_sub,dirfiles{sub_idx}{a}));
            end
        end
    end
    
    run=0;
    for run=1:length(dirfiles{sub_idx}); %for each run
        fprintf('Analyzing Sub: %s, Run: %d\n',subs{sub_idx}, run);
        
        %load relevant data from mat file
        load(fn_data{run},'output_data');
        ntrials=size(output_data,1)-1;
        
        %make matrix sample number
        samp_cell{sub_idx,run}=output_data(2:end,4);
        i=0;
        for i=1:size(samp_cell{sub_idx,run},1);
            samp_mat{sub_idx,run}(i)=str2num(samp_cell{sub_idx,run}{i,1}); 
        end
        
        %make matrix test number
        test_cell{sub_idx,run}=output_data(2:end,5);
        i=0;
        for i=1:size(test_cell{sub_idx,run},1);
            test_mat{sub_idx,run}(i)=str2num(test_cell{sub_idx,run}{i,1}); 
        end
        
        %make matrix with participant response
        resp_cell{sub_idx,run}=output_data(2:end,11);
        i=0;
        for i=1:size(resp_cell{sub_idx,run},1);
            if isempty(resp_cell{sub_idx,run}{i,1})==1; %if response wasn't recorded for some reason
                resp_mat{sub_idx,run}(i)=nan; %mark that trial as nan
            elseif sum(resp_cell{sub_idx,run}{i,1}=='NaN')==3; %if participant didn't respond; need to do this way because the result is stored as a char, so you compare that char to "NaN' and get 3 values (one for each character), so we are seeing if you get 3 1s, so sum =3
                resp_mat{sub_idx,run}(i)=0; %mark that trial as 0
            elseif strcmp(resp_cell{sub_idx,run},'0')==1;
                resp_mat{sub_idx,run}(i)=0;
            else
                resp_mat{sub_idx,run}(i)=str2num(resp_cell{sub_idx,run}{i,1}); %mark participant's response
            end
        end
        
        %make matrix with correct answer
        answer_cell{sub_idx,run}=output_data(2:end,10);
        i=0;
        for i=1:size(answer_cell{sub_idx,run},1);
            answer_mat{sub_idx,run}(i)=str2num(answer_cell{sub_idx,run}{i,1}); %mark participant's response
        end
        
        %make matrix with whether participant got trial correct 
        correct_log{sub_idx,run}=resp_mat{sub_idx,run}(:)==answer_mat{sub_idx,run}(:); %mark whether participant got answer right
        correct_mat{sub_idx,run}=double(correct_log{sub_idx,run});
        
        
        total_trials=size(resp_mat{sub_idx,run},2);
        trials_NR=length(find(resp_mat{sub_idx,run}(:)==0));
        trials_correct=length(find(correct_mat{sub_idx,run}(:)==1));
        trials_incorrect=length(find(correct_mat{sub_idx,run}(:)==0));
%         percent_correct=trials_correct/(trials_correct+trials_incorrect);
    
        %Want percent correct out of trials completed (exclude no response trials)
        percent_correct=trials_correct/(total_trials-trials_NR);
        
        %Record number of trials collected for each sample number
        num_idx=0;
        for num_idx=1:length(nums);
            num_idxs{sub_idx,run}{num_idx}=find(samp_mat{sub_idx,run}(:)==nums(num_idx));
            trails_per_samp_num{sub_idx,run}(num_idx)=length(find(resp_mat{sub_idx,run}(num_idxs{sub_idx,run}{num_idx}(:))==1))+length(find(resp_mat{sub_idx,run}(num_idxs{sub_idx,run}{num_idx}(:))==2));
        end
        
        %Record accuracy for each pair
        pairs=[4,8;8,16;16,32];
        i=0;
        for i=1:size(pairs,1); %for each pair
            correct_count_temp=0;
            total_count_temp=0;
            j=0;
            for j=1:size(correct_mat{sub_idx,run},1); %for each trial
                if samp_mat{sub_idx,run}(j)==pairs(i,1) && test_mat{sub_idx,run}(j)==pairs(i,2); %if sample matches first item in pair and test matches second item in pair
                    correct_count_temp=correct_count_temp+correct_mat{sub_idx,run}(j,1); %count whether that person got it correct (1) or not (0)
                    total_count_temp=total_count_temp+1; %count the number of trials of that pair
                elseif samp_mat{sub_idx,run}(j)==pairs(i,2) && test_mat{sub_idx,run}(j)==pairs(i,1); %or vice versa
                    correct_count_temp=correct_count_temp+correct_mat{sub_idx,run}(j,1); %count whether that person got it correct (1) or not (0)
                    total_count_temp=total_count_temp+1; %count the number of trials of that pair
                end
            end
            correct_pair{sub_idx,run}(i)=correct_count_temp/total_count_temp;
        end
        
        cntr_data_out=cntr_data_out+1;
        data_out{cntr_data_out+1,1}=subs{sub_idx};
        data_out{cntr_data_out+1,2}=output_data{2,1};
        data_out{cntr_data_out+1,3}=num2str(total_trials);
        data_out{cntr_data_out+1,4}=num2str(trials_NR);
        data_out{cntr_data_out+1,5}=num2str(trials_correct);
        data_out{cntr_data_out+1,6}=num2str(trials_incorrect);
        data_out{cntr_data_out+1,7}=num2str(percent_correct);
        data_out{cntr_data_out+1,8}=num2str(trails_per_samp_num{sub_idx,run}(1));
        data_out{cntr_data_out+1,9}=num2str(trails_per_samp_num{sub_idx,run}(2));
        data_out{cntr_data_out+1,10}=num2str(trails_per_samp_num{sub_idx,run}(3));
        data_out{cntr_data_out+1,11}=num2str(trails_per_samp_num{sub_idx,run}(4));
        data_out{cntr_data_out+1,12}=num2str(correct_pair{sub_idx,run}(1));
        data_out{cntr_data_out+1,13}=num2str(correct_pair{sub_idx,run}(2));
        data_out{cntr_data_out+1,14}=num2str(correct_pair{sub_idx,run}(3));
    end
    
end

dlmcell(strcat(path_exp,'Analysis/BehavioralResults_Updated_',datestr(now, 'mmddyy'),'.xls'),data_out);