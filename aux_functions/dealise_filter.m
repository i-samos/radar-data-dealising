function [doppler_3,phases]=dealise_filter(doppler)
%%
h1 = waitbar(0,'Dealising...');

[e1,~]=size(doppler);
vmax=  max(abs(doppler(:)));
for NNN=1:1:e1
    waitbar(NNN/e1,h1)
    gate=doppler(NNN,:);
    gate(gate==0)=nan;
    test1=abs(nansum(gate));
    test2=sum(~isnan(gate));
    assignin('base','gate',gate);
    %%
    NUM=10;
    if test1>0 && test2>NUM
        i=1;
        for a=vmax/2:vmax/3:2*vmax
            for a0=0
                for k=0:10:350
                    phase=deg2rad(k);
                    x0= [phase a a0 vmax];
                    y_1(i,1)=sine_folding(x0);
                    y_1(i,2:5)=x0;
                    i=i+1;
                end
            end
        end
        [~,q2]=min(y_1(:,1));
        x0=y_1(q2,2:5);
        clearvars y_1
        %%
        fs = numel(doppler(NNN,:)');                  % sampling rate (number of rays)
        dur = 1;                  % duration in seconds
        n = fs * dur;               % number of data points
        t = (0 : n-1) / fs;         % time vector
        f = 1;                     % frequency in Hz
        y0=( x0(3) + x0(2)*sin(2*pi*f*t'+x0(1)));
        
        b=1:numel(y0);
%         b=rad2deg(x0(1))-30:rad2deg(x0(1))+30;
        b(b>360)=b(b>360)-360;
        b(b<0)=b(b<0)+360;
        b(b==0)=360;
        b=round(b);
        
        ch1=isnan(gate);
        
        dif0=y0(b)-gate(b)';dif0=abs((dif0));dif0=nansum(dif0);
        y0=sine_folding_results(x0);
        y0(ch1)=nan;
        y01=sine_folding_results_plus90(x0);
        y01(ch1)=nan;
        dif1=y0(b)-gate(b)';dif1=abs((dif1));dif1=nansum(dif1);
        dif2=y01(b)-gate(b)';dif2=abs((dif2));dif2=nansum(dif2);
        if dif0<dif1 && dif0<dif2
            'unfolded';
            folded=0;
        elseif dif1<dif2
            'right';
            folded=1;
        elseif dif2<dif1
            'opposite';
            folded=1;
            temp=rad2deg(x0(1));
            if temp<180 && temp>=0
                temp=temp+180;
                x0(1)=deg2rad(temp);
            elseif temp<360 && temp>=180
                temp=temp-180;
                x0(1)=deg2rad(temp);
            end
        end

        y0=( x0(3) + x0(2)*sin(2*pi*f*t'+x0(1)));


        x1=x0;
        x1(1)=rad2deg(x1(1));
        x1(end+1)=NNN;
        phases(NNN,1:5)=x1;
        doppler_3(NNN,:)= doppler(NNN,:);
        doppler_1=doppler+2*vmax;
        doppler_2=doppler-2*vmax;
        doppler_11=doppler_1(NNN,:);
        doppler_11(doppler_11>( max(doppler_11)-min(doppler_11) ))=0;
        doppler_11(doppler_11==0)=nan;
        doppler_22=doppler_2(NNN,:);
        doppler_22(doppler_22<( -max(doppler_22)+min(doppler_22) ))=0;
        doppler_22(doppler_22==0)=nan;
        y0=( x0(3) + x0(2)*sin(2*pi*f*t'+x0(1)));
        y0=y0';
        for i=1:numel(doppler(NNN,:))
            if folded==1
                if abs(doppler(NNN,i))>vmax/2
                    
                    S_fft=sign(y0(1,i));
                    S_now=sign(doppler(NNN,i));
                    S_dn= sign(doppler_2(NNN,i));
                    S_up= sign(doppler_1(NNN,i));
                    if   S_fft == S_now & S_now~=0
                        doppler_3(NNN,i)=doppler(NNN,i);
                    elseif S_fft ~= S_now & S_now~=0
                        if     S_up == S_fft
                            doppler_3(NNN,i)=doppler_1(NNN,i);
                        elseif S_dn == S_fft
                            doppler_3(NNN,i)=doppler_2(NNN,i);
                        end
                    elseif S_now==0
                        doppler_3(NNN,i)= doppler(NNN,i);
                    end
                else
                    doppler_3(NNN,i)= doppler(NNN,i);
                end
            end
        end
        for i=1:numel(doppler(NNN,:))
            s1=y0(1,i);
            s2=doppler_3(NNN,i);
            if abs(s2-s1)>vmax & s2<0
                s2=s2+2*vmax;
            elseif abs(s2-s1)>vmax & s2>0
                s2=s2-2*vmax;
            end
            doppler_3(NNN,i)=s2;
        end
     elseif  test2<120
        doppler_3(NNN,:)= doppler(NNN,:);
        phases(NNN,1:4)=nan;
        phases(NNN,5)=NNN;
    end
%     if test1>0 && test2>NUM
%         plot(doppler_3(NNN,:),'m*');drawnow
%     end
end
evalin('base','clear NNN')
close(h1)
end



function y_1 = sine_folding(x)
    %% SINE_FOLDING
    % Computes the sum of absolute differences between a folded sine wave and
    % the provided gate data. The sine wave is adjusted iteratively to ensure
    % it remains within the range [-vmax, vmax].
    %
    % Inputs:
    %   - x: A vector containing parameters:
    %       x(1): Phase (in radians)
    %       x(2): Amplitude
    %       x(3): Vertical offset
    %       x(4): Maximum velocity (folding limit, vmax)
    %
    % Output:
    %   - y_1: Sum of absolute differences between the folded sine wave and the gate data

    %% Step 1: Retrieve gate data from the base workspace
    gate = evalin('base', 'gate'); % Retrieve `gate` variable from base workspace
    y_2 = gate'; % Transpose gate data for compatibility
    y_2(y_2 == 0) = NaN; % Treat zeros as NaN
    ch1 = isnan(y_2); % Create a mask for NaN values

    %% Step 2: Define time and frequency parameters
    fs = numel(y_2); % Sampling rate (number of rays)
    dur = 1; % Duration in seconds
    n = fs * dur; % Number of data points
    t = (0:n-1) / fs; % Time vector
    f = 1; % Frequency in Hz

    %% Step 3: Generate the sine wave
    y0 = x(3) + x(2) * sin(2 * pi * f * t' + x(1)); % Compute sine wave
    y0(ch1) = NaN; % Apply NaN mask from `y_2`

    %% Step 4: Fold sine wave to stay within [-vmax, vmax]
    y_1 = y0; % Initialize folded sine wave
    i = 0; % Iteration counter
    while max(abs(y_1)) > x(4) && i < 3
        % Fold values greater than vmax
        y_1(y_1 > x(4)) = y_1(y_1 > x(4)) - 2 * x(4);
        % Fold values less than -vmax
        y_1(y_1 < -x(4)) = y_1(y_1 < -x(4)) + 2 * x(4);
        i = i + 1; % Increment iteration counter
    end

    %% Step 5: Compute the sum of absolute differences
    y_1 = nansum(abs(abs(y_1) - abs(y_2))); % Ignore NaN values during computation
end


function y_1 = sine_folding_results(x)
    %% SINE_FOLDING_RESULTS
    % Generates a sine wave based on given parameters and folds it within
    % the range [-vmax, vmax].
    %
    % Inputs:
    %   - x: A vector containing parameters:
    %       x(1): Phase (in radians)
    %       x(2): Amplitude
    %       x(3): Vertical offset
    %       x(4): Maximum velocity (folding limit)
    %
    % Output:
    %   - y_1: Folded sine wave within the range [-x(4), x(4)]

    %% Extract parameters
    phase = x(1);
    amplitude = x(2);
    offset = x(3);
    vmax = x(4);

    %% Retrieve gate data from the base workspace
    gate = evalin('base', 'gate');
    y_2 = gate'; % Transpose gate data for compatibility

    %% Time and frequency settings
    fs = numel(y_2); % Sampling rate (number of rays)
    dur = 1; % Duration in seconds
    n = fs * dur; % Number of data points
    t = (0:n-1) / fs; % Time vector
    f = 1; % Frequency in Hz

    %% Generate sine wave
    y0 = offset + amplitude * sin(2 * pi * f * t' + phase);

    %% Apply folding to constrain within [-vmax, vmax]
    y_1 = y0; % Initialize folded sine wave
    i = 0; % Iteration counter
    while max(abs(y_1)) > vmax && i < 3
        % Fold values greater than vmax
        y_1(y_1 > vmax) = y_1(y_1 > vmax) - 2 * vmax;
        % Fold values less than -vmax
        y_1(y_1 < -vmax) = y_1(y_1 < -vmax) + 2 * vmax;
        i = i + 1; % Increment iteration counter
    end
end


function y_1 = sine_folding_results_plus90(x)
    %% SINE_FOLDING_RESULTS_PLUS90
    % Generates a sine wave with an additional phase shift of 180 degrees and
    % folds it within a specified velocity range.
    %
    % Inputs:
    %   - x: A vector containing parameters:
    %       x(1): Phase (in radians)
    %       x(2): Amplitude
    %       x(3): Vertical offset
    %       x(4): Maximum velocity (folding limit)
    %
    % Output:
    %   - y_1: Folded sine wave

    %% Extract parameters
    phase = x(1);
    amplitude = x(2);
    offset = x(3);
    vmax = x(4);

    %% Get gate data from the base workspace
    gate = evalin('base', 'gate');
    y_2 = gate'; % Transpose gate data for compatibility

    %% Time and frequency settings
    fs = numel(y_2); % Sampling rate (number of rays)
    dur = 1; % Duration in seconds
    n = fs * dur; % Number of data points
    t = (0:n-1) / fs; % Time vector
    f = 1; % Frequency in Hz

    %% Generate sine wave with a 180-degree phase shift
    y0 = offset + amplitude * sin(2 * pi * f * t' + phase + deg2rad(180));

    %% Apply folding to keep the sine wave within [-vmax, vmax]
    y_1 = y0; % Initialize folded wave
    i = 0; % Iteration counter
    while max(abs(y_1)) > vmax && i < 3
        % Fold values greater than vmax
        y_1(y_1 > vmax) = y_1(y_1 > vmax) - 2 * vmax;
        % Fold values less than -vmax
        y_1(y_1 < -vmax) = y_1(y_1 < -vmax) + 2 * vmax;
        i = i + 1; % Increment iteration counter
    end
end
