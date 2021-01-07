clear all
close all

subnums=[18];

subidx=0;
for subidx=1:length(subnums);
    clearvars -except subidx subnums
    viscond='CB';
    subnum=subnums(subidx);
    subids=num2str(subnum);
    if length(subids)==1;
        subids=strcat('0',subids);
    end
    
    path_exp='/Users/Shipra/Documents/Experiments/ANS_fMRI_MVPA/';
    path_results=strcat(path_exp,'ANS_fMRI_MVPA_Results/');
    path_data=strcat(path_results,'ANS_MVPA_',viscond,'_',subids,'/');
    path_timing=strcat(path_exp,'ANS_fMRI_MVPA_Timing/CodeConditions_StimDelayTogether/');
    if exist(path_timing)==0;
        mkdir(path_timing);
    end

    nums=[4,8,16,32];
    lists={'TM','EM'};

    dirfilest = dir([path_data,'*.mat']);

    nTRs=340;

    a=0;
    i=0;
    for i=1:size(dirfilest);
        if strcmp(dirfilest(i).name,'.')==0 &&  strcmp(dirfilest(i).name,'..')==0 &&  strcmp(dirfilest(i).name,'.DS_Store')==0;
           a=a+1;
           dirfiles{a} = cellstr(dirfilest(i).name);
           fn_data{a}=char(strcat(path_data,dirfiles{a}));
        end
    end

    run=0;
    for run=1:size(dirfiles,2);
        %load data
        load(fn_data{run},'output_data');

        %start counter for each list x number combination
        cntr_num{run}=zeros(length(lists),length(nums)); %2 lists by 4 numbers

        %isolate just the timing data (cell format)
        timing_cell{run}=output_data(2:end,16:22); %16:22 instead of 17:end for subs after CB_03

        %go through each row of the data
        i=0;
        for i=1:size(timing_cell{run},1);
            pair{run}(i,1)=str2num(output_data{i+1,4}); %first number in pair
            pair{run}(i,2)=str2num(output_data{i+1,5}); %second number in pair

            %find the idx of the current number in the number list
            num_idx{run}(i)=find(nums==pair{run}(i,1)); 

            %get the list for the current trial
            list{run}(i)=str2num(output_data{i+1,6});

            %get the response for the current trial
            responses{run}(i)=str2num(output_data{i+1,11});

            %go through each column of the timing data and convert it to a
            %number and save it in mat format
            j=0;
            for j=1:size(timing_cell{run},2);
                format long
                timing_mat{run}(i,j)=str2num(timing_cell{run}{i,j});
            end
        end

        %find all trials where person didn't respond
        no_resp_idxs{run}=find(responses{run}(:)==0);

        %when was the experiment triggered
        ts_trigger_received=str2num(output_data{2,14});%changed from 15 to 14 7/19/17

        %subtract trigger time from every time in timing_mat
        timing_mat{run}(:,:)=timing_mat{run}(:,:)-ts_trigger_received;

        timing_mat_drops{run}=timing_mat{run}(no_resp_idxs{run}(:,1),:); %save drop trial timing 

        timing_tap1{run}(:,1)=timing_mat{run}(:,1); %tap 1 onset
        timing_tap1{run}(:,2)=timing_mat{run}(:,2)-timing_mat{run}(:,1); %duration of tap
        timing_tap1{run}(:,3)=1;
        timing_tap1{run}(no_resp_idxs{run}(:,1),:)=[]; %remove all no response trials

        i=0;
        for i=1:size(timing_cell{run},1); %loop through each trial
            if isempty(find(no_resp_idxs{run}(:)==i))==1; %if not a no response trial
                cntr_num{run}(list{run}(i),num_idx{run}(i))=cntr_num{run}(list{run}(i),num_idx{run}(i))+1;
                timing_cond{run}{list{run}(i),num_idx{run}(i)}(cntr_num{run}(list{run}(i),num_idx{run}(i)),1)=timing_mat{run}(i,2); %stim 1 onset
                timing_cond{run}{list{run}(i),num_idx{run}(i)}(cntr_num{run}(list{run}(i),num_idx{run}(i)),2)=timing_mat{run}(i,4)-timing_mat{run}(i,2); %stim 2 onset - stim 1 onset (duration of stim 1 + delay)
                timing_cond{run}{list{run}(i),num_idx{run}(i)}(cntr_num{run}(list{run}(i),num_idx{run}(i)),3)=1;
            end
        end

        i=0;
        for i=1:length(lists); 
            j=0;
            for j=1:length(nums);
                fn_timing_cond{run}{i,j}=strcat(path_timing,'ANS_MVPA_',viscond,'_',subids,'-ans_mvpa_0',num2str(run),'-',num2str(nums(j)),'_',lists{i},'.txt');
                dlmwrite(fn_timing_cond{run}{i,j},timing_cond{run}{i,j},'delimiter','\t');
            end
        end

        timing_stim2{run}(:,1)=timing_mat{run}(:,4); %stim2 onset
        timing_stim2{run}(:,2)=timing_mat{run}(:,5)-timing_mat{run}(:,4); %tap 2 onset - stim 2 onset
        timing_stim2{run}(:,3)=1;
        timing_stim2{run}(no_resp_idxs{run}(:,1),:)=[]; %remove all no response trials

        timing_tap2resp{run}(:,1)=timing_mat{run}(:,5); %tap 2 onset
        timing_tap2resp{run}(:,2)=timing_mat{run}(:,7)-timing_mat{run}(:,5); %resp stop - tap 2 onset (duration of tap 2, and resp)
        timing_tap2resp{run}(:,3)=1;
        timing_tap2resp{run}(no_resp_idxs{run}(:,1),:)=[]; %remove all no response trials

        timing_drops{run}(:,1)=timing_mat_drops{run}(:,1); %tap onset
        timing_drops{run}(:,2)=timing_mat_drops{run}(:,7)-timing_mat_drops{run}(:,1); %duration of entire trial excluding rest
        timing_drops{run}(:,3)=1;

        fn_timing_tap1{run}=strcat(path_timing,'ANS_MVPA_',viscond,'_',subids,'-ans_mvpa_0',num2str(run),'-tap1.txt');
        fn_timing_stim2{run}=strcat(path_timing,'ANS_MVPA_',viscond,'_',subids,'-ans_mvpa_0',num2str(run),'-stim2.txt');
        fn_timing_tap2resp{run}=strcat(path_timing,'ANS_MVPA_',viscond,'_',subids,'-ans_mvpa_0',num2str(run),'-tap2resp.txt');
        fn_timing_drops{run}=strcat(path_timing,'ANS_MVPA_',viscond,'_',subids,'-ans_mvpa_0',num2str(run),'-drops.txt');

        dlmwrite(fn_timing_tap1{run},timing_tap1{run},'delimiter','\t');
        dlmwrite(fn_timing_stim2{run},timing_stim2{run},'delimiter','\t');
        dlmwrite(fn_timing_tap2resp{run},timing_tap2resp{run},'delimiter','\t');
        dlmwrite(fn_timing_drops{run},timing_drops{run},'delimiter','\t');

        %1=tap 1 start
        %2=sample 1 start
        %3=delay 1 start
        %4=stim 2 start
        %5=tap 2 start
        %6=resp start
        %7=resp end
        %8=rest start
        %9=trial/rest end
    end
end


