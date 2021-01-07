%BeepMaker(number,match_method,desired_duration,ear,path_out,optional_wav_file_name)
%       number=some integer
%       match method=(1) TD match (2) elem duration match
%       desired duration=duration in seconds (entire duration if TD match; [on_dur off_dur] if elem match)
%       ear=left(1), right(2), or both(3)
%       path_out=point to a folder
%       optional_wav_file_name=enter wav file name that will be output in addition
%       to everything else (don't put .wav, will add it automatically).
% Updated on 7/17/16 to add something to make sure that the on time and off
% times occupied the correction proportion of the duration on duration
% matched trials. Before, if you made a 3 second stimulus with 10 beeps 2
% times, one time, the total "on time" might be 2 seconds and another time
% it will be 2.4 seconds. I added something to make sure that if you have a
% 3 sec stim with 10 beeps, it will always have a fixed proportion of the
% TD as "on time" and fixed as "off time". You can adjust that proportion
% in this script.
function BeepMaker(number,match_method,desired_duration,ear,path_out,optional_wav_file_name);

    if nargin<5
       optional_wav_file_name='';
    end

    freq=440;

    element_duration_on_min=40;
    element_duration_on_max=60;
    element_duration_off_min=50;
    element_duration_off_max=60;
    
    expected_mean=60;
    fade_window=5;
    sampling_rate=96000;

%     dur_buffer=0.025;
    dur_buffer=0.005; %Made buffer window really small.
    
    if match_method==1; %TOTAL DURATION MATCH
        
        percentTimeOn=.6; %percent of total duration during which there should be beeps playing
        percentTimeOff=1-percentTimeOn; %percent of total duration during which there should be silence
        
        total_duration=(desired_duration)-(dur_buffer*2);

        fn_wav=strcat(path_out,num2str(number),'Beeps_TDMatch_Desired',num2str(desired_duration),'_actual',num2str(total_duration),'_',datestr(now, 'ddmmyyHHMMSS'),'.wav');
        fn_wav=strcat(path_out,num2str(number),'Beeps_TDMatch_Desired',num2str(desired_duration),'_actual',num2str(total_duration),'_',datestr(now, 'ddmmyyHHMMSS'),'.xls');

        if exist(fn_wav)==2;
            fn_wav=strrep(fn_wav,'_1.wav','_2.wav');
            fn_xls=strrep(fn_xls,'_1.xls','_2.xls');
        end

        if exist(fn_wav)==2;
            fn_wav=strrep(fn_wav,'_2.wav','_3.wav');
            fn_xls=strrep(fn_xls,'_2.xls','_3.xls');
        end

        i=0;
        for i=1:number;
           done=false;
           while done==false;
               onc=(geornd(1/expected_mean)+element_duration_on_min)*(1/1000); %At least 20 ms
               offc=(geornd(1/expected_mean)+element_duration_off_min)*(1/1000); %At least 20 ms
               if  offc<element_duration_off_max && onc<element_duration_on_max; %On no more than 60 ms; Off no more than 35 ms
                   ont(i)=onc;
                   offt(i)=offc;
                   done = true;
               end
           end
        end
        offt(i)=[]; %Removing last off time bc dont need it
        tdt=sum(ont(:))+sum(offt(:)); 

        %Make first [dur_tdmatch] seconds long
        ont2=(ont(:))*(total_duration/tdt);
        offt2=(offt(:))*(total_duration/tdt);
        tdt2=sum(ont2(:))+sum(offt2(:));

        %Correct the timings so that the on and off times occupy the right
        %percentage of the stimulus (according to percentTimeOn and
        %percentTimeOff
        on=ont2+(((percentTimeOn*tdt2)-sum(ont2))/(size(ont2,1))); %find out how many seconds the total on time should be, subtract that from the actual total on time. divide that difference by the number of beeps and then add that number to each of the beeps.
        off=offt2+(((percentTimeOff*tdt2)-sum(offt2))/(size(offt2,1)));
        td=sum(on(:))+sum(off(:));

    elseif match_method==2; %ELEMENT DURATION MATCH
        element_duration_on=desired_duration(1);
        element_duration_off=desired_duration(2);
%         element_duration_on=.06;
%         element_duration_off=.04;
        element_duration_total=(number*element_duration_on)+((number-1)*element_duration_off);
        element_duration_total_on=number*element_duration_on;
        element_duration_total_off=(number-1)*element_duration_off;
        element_duration_match_off_min=.02;
        element_duration_match_on_min=.04;
        
        if element_duration_on<element_duration_match_on_min || element_duration_off<element_duration_match_off_min;
            error('element on or off duration too short');
        end
        
        i=0;
        for i=1:number;
            on(i,1)=element_duration_match_on_min; %use the minimum amount of on time to begin with (0.04 sec)
            if i~=number; %don't do the last off time
                off(i,1)=element_duration_match_off_min; %use the minimum amount of off time to begin with (0.02 sec)
            end
        end

        %ADJUSTING ON TIMES FIRST

        %determine how much off time is "remaining" because expected off time
        %should be .06*number-1, but right now it is at .04*number-1
        remaining_on_time=((number-1)*element_duration_on)-((number-1)*element_duration_match_on_min);
        remaining_on_time_string=num2str(remaining_on_time*100);
        remaining_on_time_double=str2double(remaining_on_time_string);

        %randomly add somewhere between .01 and 0.04 seconds to some of the on
        %times
        i=0;
        for i=1:number-1;
            if remaining_on_time_double>0;
                done=false;
                while done==false
                    add_time=randi(remaining_on_time_double);
                    if add_time<4
                        done=true;
                    else
                        done=false;
                    end
                end
                on(i,1)=on(i,1)+(add_time/100);
                remaining_on_time_double=remaining_on_time_double-add_time;
            end
        end

        %if there is still time remaining, add it to a random on time
        if remaining_on_time_double>0;
            cnum=randi(number-1);
            on(cnum,1)=on(cnum,1)+(remaining_on_time_double/100);
        end

        %randomize the position of the on times
        on(:,1)=on(randperm(size(on,1)),1);

        %ADJUST OFF TIMES SECOND

        %determine how much off time is "remaining" because expected off time
        %should be .04*number-1, but right now it is at .02*number-1
        remaining_off_time=((number-1)*element_duration_off)-((number-1)*element_duration_match_off_min);
        remaining_off_time_string=num2str(remaining_off_time*100);
        remaining_off_time_double=str2double(remaining_off_time_string);

        %randomly add somewhere between .01 and 0.04 seconds to some of the off
        %times
        i=0;
        for i=1:number-1;
            if remaining_off_time_double>0;
                done=false;
                while done==false
                    add_time=randi(remaining_off_time_double);
                    if add_time<4
                        done=true;
                    else
                        done=false;
                    end
                end
                off(i,1)=off(i,1)+(add_time/100);
                remaining_off_time_double=remaining_off_time_double-add_time;
            end
        end

        %if there is still time remaining, at it to a random off time
        if remaining_off_time_double>0;
            cnum=randi(number-1);
            off(cnum,1)=off(cnum,1)+(remaining_off_time_double/100);
        end

        %randomize the position of the off times
        off(:,1)=off(randperm(size(off,1)),1);

        td=sum(on(:,1))+sum(off(:,1));

        fn_wav=strcat(path_out,num2str(number),'Beeps_ElemMatch_On',num2str(element_duration_on),'_Off','_',datestr(now, 'ddmmyyHHMMSS'),'.wav');
        fn_wav=strcat(path_out,num2str(number),'Beeps_ElemMatch_On',num2str(element_duration_on),'_Off','_',datestr(now, 'ddmmyyHHMMSS'),'.xls');
    end
    
    %MAKE BEEPS
    i=0;
    for i=1:number; 
        beep{i}=MakeBeep(freq,on(i,1),sampling_rate);
        beep{i}(1,round((end-(fix(end/(fade_window))))):end)=fade(beep{i}(1,round((end-(fix(end/(fade_window))))):end),1);
        beep{i}(1,(1:round(end/(fade_window))))=fade(beep{i}(1,(1:round(end/(fade_window)))),2);
    end

    %Make long string of beeps
    on_total_samp=0;
    i=0;
    for i=1:number;
        on_total_samp=on_total_samp+size(beep{i},2);
    end

    off_total_samp=0;
    i=0;
    for i=1:number-1;
        off_total_samp=off_total_samp+(off(i,1)*sampling_rate);
    end

    beep_string_total_samp=on_total_samp+off_total_samp;

    beep_string=nan(1,ceil(beep_string_total_samp)); %make a string of zeros for the number of samples that there are in all on and off times combined

    i=0;
    for i=1:number;
        last_empty_cell=find(isnan(beep_string),1); %find the first nan

        %plug in the beep (on)
        beep_string(1,last_empty_cell:(last_empty_cell-1)+size(beep{i},2))=beep{i}(1,:);

        %plug in the pause (off)
        if i~=number;
            last_empty_cell=find(isnan(beep_string),1); %find the first nan
            beep_string(1,last_empty_cell:(last_empty_cell-1)+ceil(off(i,1)*sampling_rate))=0;
        end
    end
    
    %ADDED THIS TO HAVE BEEPS PLAY ON ONE SIDE
    if ear==1; %left ear
        beep_string(2,1:length(beep_string(1,:)))=0;
        beep_string=beep_string'; %need to do this because stereo information needs to be 2 columns
    elseif ear==2; %right ear
        beep_string(2,1:length(beep_string(1,:)))=beep_string(1:length(beep_string(1,:)));
        beep_string(1,1:length(beep_string(1,:)))=0;
        beep_string=beep_string';
    elseif ear==3; %both ears
    end

    %organizing on and off data
    output_data{1,1}='On times';
    output_data{1,2}='Off times';
    % output_data{1,3}='Time it took to initialize beep player';

    for i=1:number;
        output_data{i+1,1}=num2str(on(i,1));
        if i ~= number;
            output_data{i+1,2}=num2str(off(i,1));
        end
    %     output_data{i+1,3}=num2str(ts_testerstop(i));
    end

    if isempty(optional_wav_file_name)==0; %if person has entered an option wav file name
        optional_xls_file_name=strcat(path_out,optional_wav_file_name,'.xls');
        optional_wav_file_name=strcat(path_out,optional_wav_file_name,'.wav');
        
        audiowrite(optional_wav_file_name,beep_string,sampling_rate);
        dlmcell(optional_xls_file_name,output_data);
    else
        dlmcell(fn_xls,output_data);
        %write out wav file
        audiowrite(fn_wav,beep_string,sampling_rate);
    end
end