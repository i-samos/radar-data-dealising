%% initial calculations
clear
close all
load('sample_data.mat')


Azimuth(401:end,:)=[];
dbz(401:end,:)=[];
Distance(401:end,:)=[];
Elevation(401:end,:)=[];
lat(401:end,:)=[];
lon(401:end,:)=[];
vel(401:end,:)=[];

limit = max(abs(vel(:)));


% Add folder 'aux_functions' plus all subfolders to the path.
addpath('aux_functions');

%% De-aliase process
% interactive mode: 1 for plot on each step, 0 for no plots
interactive = 1; 

% algorithm
[vel_algorithm,vel_expasnion_and_algorithm,vel_expansion,amplitudes,phases_alg1,phases] = dealise_velocities(vel,dbz,interactive);

%% Figures

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
pcolor(lon,lat,vel_expansion);
axis square;
shading flat;
caxis([-limit limit]);
colormap(parula);
title('Dealiased Velocities');
xlabel('Longitude');
ylabel('Latitude');

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
pcolor(vel_algorithm); shading flat;axis square; caxis([-limit limit])
title('Dealiased Velocities with mathematic algorithm');
xlabel('Azimuth');
ylabel('Distance');

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
pcolor(vel_expasnion_and_algorithm); shading flat;axis square; caxis([-limit limit])
title('Dealiased Velocities with expansion algorithm');
xlabel('Azimuth');
ylabel('Distance');

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
pcolor(vel); shading flat;axis square; caxis([-limit limit])
hold on
plot(phases,1:length(phases),'-ro')
plot(phases+size(vel,2),1:length(phases),'-ro')
plot(phases-size(vel,2),1:length(phases),'-ro')
title('Original Velocities and phases with fft');
xlabel('Azimuth');
ylabel('Distance');

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
pcolor(vel); shading flat;axis square; caxis([-limit limit])
hold on
plot(phases_alg1,1:length(phases_alg1),'ko')
plot(phases_alg1+size(vel,2)/2,1:length(phases_alg1),'ko')
plot(phases_alg1+size(vel,2),1:length(phases_alg1),'ko')
plot(phases_alg1-size(vel,2)/2,1:length(phases_alg1),'ko')
plot(phases_alg1-size(vel,2),1:length(phases_alg1),'ko')
title('Original Velocities and phases using fitted aliased sines');
xlabel('Azimuth');
ylabel('Distance');

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
hold on
plot(wrapTo360(phases),'ro')
plot(wrapTo360(phases_alg1),'bo')
title('Phases')
xlabel('Distance');
ylabel('Degrees');
ylim([-10 370])
grid on

figure('Color', 'white', 'visible', 'on', 'Renderer', 'opengl', 'Position', [0 0 1600 1200]);
hold on
plot(amplitudes,'ro')
title('Amplitude')
xlabel('Distance');
ylabel('m/s');
grid on




%% visualize sines of aliased and dealiased velocities
figure
subplot(2,2,2)
pcolor(vel_expasnion_and_algorithm);shading flat;caxis([-limit limit]);
ylim([0 200])

subplot(2,2,1)
pcolor(vel);shading flat;caxis([-limit limit]);
ylim([0 200])



for i=1:200%length(vel_expasnion_and_algorithm(:,1))
    subplot(2,2,2)
    hold on
    Line1=line(1:length(vel_expasnion_and_algorithm(1,:)),(1:length(vel_expasnion_and_algorithm(1,:)))*0+i,'color','blue','linewidth',1.0);
    subplot(2,2,1)
    hold on
    Line2=line(1:length(vel_expasnion_and_algorithm(1,:)),(1:length(vel_expasnion_and_algorithm(1,:)))*0+i,'color','blue','linewidth',1.0);
    subplot(2,2,4)
    hold on
    line(1:length(vel(1,:)),(1:length(vel(1,:)))*0+limit,'color','red','linewidth',1.0);
    line(1:length(vel(1,:)),(1:length(vel(1,:)))*0-limit,'color','red','linewidth',1.0);
    Linea=plot(1:length(vel_expasnion_and_algorithm(1,:)),vel_expasnion_and_algorithm(i,:),'bo')
    xlim([-5 (size(vel,2)+5)])
    ylim([-2*limit 2*limit])
    title(num2str(i))
    hold off
    subplot(2,2,3)
    hold on
    line(1:length(vel(1,:)),(1:length(vel(1,:)))*0+limit,'color','red','linewidth',1.0);
    line(1:length(vel(1,:)),(1:length(vel(1,:)))*0-limit,'color','red','linewidth',1.0);
    Lineb=plot(1:length(vel(1,:)),vel(i,:),'bo')
    xlim([-5 (size(vel,2)+5)])
    ylim([-2*limit 2*limit])
    title(num2str(i))
    hold off
    drawnow
    subplot(2,2,2)
    delete(Line1)
    subplot(2,2,1)
    delete(Line2)
    subplot(2,2,3)
    delete(Lineb)
    subplot(2,2,4)
    delete(Linea)
    
end
