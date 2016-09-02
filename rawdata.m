%{
    rawdata.m
    @purpose plots basic data about an MT
    @version 0.8.4
    @author George Saussy and Veikko Geyer
%}


h2=figure;


% plot filiment
subplot(2,3,1);
hold on;
xlabel('X position (m)');
ylabel('Y position (m)');
title('Filiment Shape');
hold off;
for j=1:size(FilamentData.Data,2) % loops over frames
    if ~isempty(FilamentData.Data{j})   
       % color
       subplot(2,3,1)
       cc = jet(size(FilamentData.Data,2)); % or hsv 
       hold on; 
       x=FilamentData.Data{j}(:,1).*1e-9;
       y=FilamentData.Data{j}(:,2).*1e-9;
       plot(x,y,'color',cc(j,:));
       axis equal;
       hold off; 
    end
end


% plot angle
subplot(2,3,2)
hold on;
title('Tangent Angle (\theta(s))');
xlabel('Arclength (m)');
ylabel('Tangent Angle (rad)');
for j=1:numFrames % loops over frames
   if ~isempty(FilamentData.Data{j}) 
        x=FilamentData.Data{j}(:,1).*1e-9;
        y=FilamentData.Data{j}(:,2).*1e-9;
        psi=unwrap(2.*FilamentData.Data{j}(1:end-1,5),1)./2;
        l = cumsum(sqrt(diff(x).^2 + diff(y).^2));
        hold on;
        plot(l, psi);
        hold off;
   end
                
end


% plot length
subplot(2,3,3)
hold on;
title('Observed Length in Each Frame');
xlabel('Frame Number');
ylabel('Length (m)');
plot(LengthAtTime);
hold off;


% plot modes, time series
subplot(2,3,4)
hold on;
title('Cos Mode Time Series');
xlabel('Frame Number');
ylabel('Amplitude (rad)');
hold off;
for i=1:size(modeAmp,1) 
    hold on;
    plot(modeAmp(i,:));
    hold off;
end


% plot modes, scater
subplot(2,3,5)
xlabel('Mode number')
ylabel('Amplitude (rad)')
for m=1:size(modeAmp,2)
    hold on; 
    plot((modeAmp(:,m)),'.k') % Cos modes
end
