path_exp='/Users/Shipra/Documents/Experiments/ANS_fMRI_MVPA/ANS_fMRI_MVPA_';
path_stim=strcat(path_exp,'Stim/');

fn_stim_info_temp=strcat(path_stim,'Stimulus_Information_Template.txt');

% condition,sample number,test number,match list,congruence,sample duration,test duration
stim_info_temp=dlmread(fn_stim_info_temp,'\t');

%(1) 4 TD Match List
%(2) 8 TD Match List
%(3) 16 TD Match List
%(4) 32 TD Match List
%(5) 4 Elem Match List
%(6) 8 Elem Match List
%(7) 16 Elem Match List
%(8) 32 Elem Match List

run_fmt=[...
    1,2,3,4,5,6,7,8,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,1,1,8,7,6,5,4,3,2;...
    3,4,5,6,7,8,1,2,2,1,8,7,6,5,4,3,4,5,6,7,8,1,2,3,3,2,1,8,7,6,5,4;...
    5,6,7,8,1,2,3,4,4,3,2,1,8,7,6,5,6,7,8,1,2,3,4,5,5,4,3,2,1,8,7,6;...
    7,8,1,2,3,4,5,6,6,5,4,3,2,1,8,7,8,1,2,3,4,5,6,7,7,6,5,4,3,2,1,8;...
    1,2,3,4,5,6,7,8,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,1,1,8,7,6,5,4,3,2;...
    3,4,5,6,7,8,1,2,2,1,8,7,6,5,4,3,4,5,6,7,8,1,2,3,3,2,1,8,7,6,5,4;...
    5,6,7,8,1,2,3,4,4,3,2,1,8,7,6,5,6,7,8,1,2,3,4,5,5,4,3,2,1,8,7,6;...
    7,8,1,2,3,4,5,6,6,5,4,3,2,1,8,7,8,1,2,3,4,5,6,7,7,6,5,4,3,2,1,8];

%Find the indexes of each condition for each run
nconds=8;
i=0;
for i=1:size(run_fmt,1);
    j=0;
    for j=1:nconds;
        cond_idxs{i}(j,:)=find(run_fmt(i,:)==j);
    end
end

%Find the indexes of each condition in the stimulus information
nconds=8;
i=0;
for i=1:nconds;
    cond_idxs_stim_info(i,:)=find(stim_info_temp(:,1)==i);
end

element_duration_on=.06;
element_duration_off=.04;

max_row=1; %each row from the stimulus information gets used only once
i=0;
for i=1:size(run_fmt,1); %for each run
    path_stim_run=strcat(path_stim,'Run_',num2str(i),'/');
    mkdir(path_stim_run);
    fn_out_correct_answers=strcat(path_stim_run,'Run_',num2str(i),'_Correct_Answers.csv');
    fn_out_stim_info=strcat(path_stim_run,'Run_',num2str(i),'_Stimulus_Information.csv');
    
    cntr_cond=zeros(nconds,size(cond_idxs_stim_info,2)); %4 trials per condition per run; counter for each condition's instantiation from the stimulus information template--each condition's instantiation gets used once per run
    j=0;
    for j=1:size(run_fmt,2); %for each trial
        if run_fmt(i,j)~=0; %if rest
        
            %Decide which stim info row to use
            done=false;
            while done==false;
                crowc=randi(size(cond_idxs_stim_info,2)); %choose an idx randomly from the number of cond idxs there are in the stim info (4)
                if cntr_cond(run_fmt(i,j),crowc)+1<=max_row;
                    cntr_cond(run_fmt(i,j),crowc)=cntr_cond(run_fmt(i,j),crowc)+1;
                    stim_info{i}(j,:)=stim_info_temp(cond_idxs_stim_info(run_fmt(i,j),crowc),:);
                    
                    %writing stim info into cell array so we can write out
                    k=0;
                    for k=1:size(stim_info_temp,2);
                        stim_info_cell{i}{j,k}=stim_info{i}(j,k);
                    end
                    
                    done=true;
                else
                    done=false;
                end
            end
        
            %Make the sample stimulus
            fn_stim_samp{i,j}=strcat('Trial_',num2str(j),'_Sample');
            if stim_info{i}(j,1)<=4; %TD Match
                BeepMaker(stim_info{i}(j,2),stim_info{i}(j,4),stim_info{i}(j,6),3,path_stim_run,fn_stim_samp{i,j});
            elseif stim_info{i}(j,1)>=5; %Elem Match
                BeepMaker(stim_info{i}(j,2),stim_info{i}(j,4),[element_duration_on element_duration_off],3,path_stim_run,fn_stim_samp{i,j});
            end
            
            %Make the test stimulus
            fn_stim_test{i,j}=strcat('Trial_',num2str(j),'_Test');
            BeepMaker(stim_info{i}(j,3),1,stim_info{i}(j,7),3,path_stim_run,fn_stim_test{i,j});

            %Record correct answer
            if stim_info{i}(j,2)>stim_info{i}(j,3);
                correct_answer{i}{j}=1;
            else
                correct_answer{i}{j}=2;
            end
        else %rest
            correct_answer{i}{j}=0;
            stim_info{i}(j,size(stim_info_temp,2))=0;
            %writing stim info into cell array so we can write out
            k=0;
            for k=1:size(stim_info_temp,2);
                stim_info_cell{i}{j,k}=stim_info{i}(j,k);
            end
        end
    end
    
    %Write out correct answers and stimulus information
    dlmcell(fn_out_correct_answers,correct_answer{i});
    dlmcell(fn_out_stim_info,stim_info_cell{i});
end
