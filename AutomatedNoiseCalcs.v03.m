clear;
fclose('all');
%-----------------------------------------------------
%
% Matt Ayres, 27 Dec 2021
% For calculation of A_automated in Symes et al. 2022
%
%-----------------------------------------------------

rootdirectory='C:\Ayres\MatLab\sound\2020';
wavdirectory='D:\HB.2016.300Recordings';
outroot='C:\Ayres\MatLab\sound\2020\outwav';
cd(rootdirectory);
infile ='Background-noise.automated.v02.xlsx';
[num,txt]=xlsread(infile, 'matlabin');
descriptors=txt;
descriptors=descriptors(2:length(descriptors),:);   % deletes label row
filenames=descriptors(:,6);
nfiles = int64(length(filenames));      % number of files to process
f=int64(0);                         % makes f an integer to (unsuccessfully dodge some warning messages
m=int64(0);                         % ""

subsample=60;       % duration in secon of subsamples from which to draw snips
sniplength=1;           % duration of time snips (seconds) from which to calculate sound energy
snipoverlap=0.9;           % proportion that one snip overlaps with the next
gap=1;            % seconds at start and end of each minute to skip
subsamplelength=subsample-2*gap;    % 58 seconds
nminutes=int64(10);         % number of minutes per sound file to analyze
noisepercentile=0.10;       % quantile for 'noise' in freq distribution of snips

noise=zeros(nfiles, nminutes);
for f=1:nfiles
    f
    cd(wavdirectory);
    infile1=strtrim(filenames(f));
    infile2=strcat(infile1,'.wav');
    infile3=char(infile2);
    [y1,Fs] = audioread(infile3);       % input sound file

    % calculate number of snips per minute for middle 58 sec of each minute
    nsubsamples=floor((length(y1)/Fs)/subsample);
        if nsubsamples>10
            nusbsamples=10;          % restrict to first 10 min for longer recordings
        end
    numerator=subsamplelength;  % total sec to analyze per subsample (e.g., 58 sec / min)
    denominator=sniplength*(1-snipoverlap); % adjust as needed for snip overlap
    nsnips=floor(numerator/denominator);    % number of snips for which to calculate sound energy
 
    for m=1:nminutes      % for each minute
        minute=m-1  % calculate sound energy for minutes 0 to 0       
            startmin=(minute*60+gap)*Fs+1;
            finishmin=startmin+(60)*Fs+1;
                if finishmin>length(y1)
                    finishmin=length(y1)        % trap for sound files that are a sec or two short
                end
        y=y1(startmin:finishmin,1);     % sound vector for selected minute

        soundenergy=zeros(1,nsnips);      % zero the matrix for total sound energy per snip
        for s=1:nsnips
            snipstart=int64((s-1)*(sniplength*(1-snipoverlap))*Fs+1);
            snipfinish=int64(snipstart+sniplength*Fs);
                include=1;
                if snipfinish>length(y)        % trap for when last snips exceed file length
                    include=0       
                end
            if include==1    
                snip=y(snipstart:snipfinish);
                soundenergy(s)=std(snip);        % standard deviation of values in snip; represents total sound energy
            end
        end
        noise(f,m)=quantile(soundenergy,noisepercentile);    % 10th percentile of sound energy in nsnips
        
    end
end    




    