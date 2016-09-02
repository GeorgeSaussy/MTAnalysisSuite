%{
    preperation.m
    @purpose does all the preprocessing before any analysis and plotting is done
    @version 0.8.4
    @author George Saussy
%}

index=0; % counter to keep track of what number frame used the loop is on
for j=1:size(FilamentData.Data,2) % loop over every frame 
    
    if ((~useFrameRange && ~isempty(FilamentData.Data{j})) || (useFrameRange && any(j==frameRange))) % Determines if the frame is usable
        index=index+1; % [] increment index when the frame is used
        x=FilamentData.Data{j}(:,1).*1e-9; % [m] read MT x-coordinate data from frame
        y=FilamentData.Data{j}(:,2).*1e-9; % [m] read MT y-coordinate data from frame
        delta_x=FilamentData.Data{j}(:,3).*1e-9; % [m] read MT x-coordinate data error from frame
        delta_y=FilamentData.Data{j}(:,4).*1e-9; % [m] read MT y-coordinate data error from frame
        psi=unwrap(2.*FilamentData.Data{j}(1:end-1,5),1)./2; % [rad] read MT angle data from frame 
        delta_psi=abs(FilamentData.Data{j}(1:end-1,6)); % [rad] read MT angle data error from frame

        epsilon(index)=mean((delta_x.^2+delta_y.^2)/2); % [m^2] normal-to-MT position error estimate (used for Gittes error estimate for mode variences)
        N(index)=size(x,1); % number of points on the MT in frame

        l=cumsum(sqrt(diff(x).^2 + diff(y).^2)); % [m] arc length of MT from beginning indexed by given points
        Length=l(end); % [m] length of MT in frame (estimate)
        LengthAtTime(index)=Length; % [m] store the length for later processing

        ds=sqrt(diff(x).^2 + diff(y).^2); % [m] difference in point position
        delta_ds = 1:size(ds,1); % [m^2] (to calculate) error in difference in point position TODO check unit
        for k=1:size(ds,1)
           delta_ds(k)=(abs(x(k+1)-x(k))*(delta_x(k+1)+delta_x(k))+abs(y(k+1)-y(k))*(delta_y(k+1)+delta_y(k)))/ds(k);
        end
        delta_l=cumsum(delta_ds); % [m^2] error in length of MT in frame TODO check unit

        for k=1:maxMode % loop over mode numbers
           amp=0; % [rad]
           delta_amp=0; % [rad^2]
           last=0; % [m]  
           delta_last=0; % [m^2]
           for bit=1:size(l,1) % loop over the length of the MT
               amp=amp+(sin(l(bit)*k*pi/Length)-sin(last*k*pi/Length))/(k*pi/Length).*psi(bit);
               delta_amp=delta_amp+abs((sin(l(bit)*k*pi/Length)-sin(last*k*pi/Length))/(k*pi/Length).*delta_psi(bit))+(delta_l(bit)*abs(cos(l(bit)*k*pi/Length))+delta_last*abs(cos(last*k*pi/Length))).*abs(psi(bit));
               last=l(bit);
               delta_last=delta_l(bit);
           end
           modeAmp(k,j)=amp*2/Length; % [rad] k-th cos mode amplitude of j-th frame of MT shape
           delta_modeAmp(k,j)=delta_amp*2/Length; % [rad^2] error in k-th cos mode amplitude of j-th frame of MT shape
        end
    end
end

modeVar=zeros(1,maxMode); % [rad^2] to calculate -- variences of the cos modes of MT shape
for j=1:maxMode % loop over cos modes
    modeVar(j)=var(modeAmp(j,:));
end

% TODO unit of Epsilon is [m], unit of epsilon(.) is [m^2], choose which 
modeVarNoise=zeros(1,maxMode); % [rad^2] to calculate -- systematic error in variences of the cos modes of MT shape calulation (uses Gittes method)
for j=1:maxMode % loop over modes
    if useCalculatedNormalError
    	modeVarNoise(j)=4*Epsilon*(1+(mean(N)-1)*sin(j*pi/2/mean(N)));
    else
        modeVarNoise(j)=4*mean(epsilon)*(1+(mean(N)-1)*sin(j*pi/2/mean(N)));
    end
end 

fitNum=0; % [] to calculate -- the number of modes that can be fit (uses Gittes method)
for j=2:maxMode % loop over modes
    if modeVarNoise(j-1)/modeVar(j-1)<.5 && modeVarNoise(j)/modeVar(j)>.5 && fitNum==0
        fitNum=j-1;
    end
end
fitNum % print fitNum
modeVar1=modeVar(1:fitNum)-modeVarNoise(1:fitNum); % [rad^2] adjusted mode varience for systematic noise

delta_modeVar1=startNum:fitNum; % [rad^4] to calculate -- error in adjusted mode varience for systematic noise
for j=startNum:fitNum % loop over modes in fit range
    delta_modeVar1(j)=modeVar1(j)*sqrt(2/(mean(N)-1));
end;
