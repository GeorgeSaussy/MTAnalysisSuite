%{
    statistics.m
    @purpose perform and plot some basic statistics on the MT
    @version 0.8.4
    @author George Saussy
%}


h3=figure;


% plot ratio of noise varience to measured varience
subplot(2,2,1)
hold on;
title('Ratio of Noise Varience to Measured Varience')
xlabel('Mode Number')
ylabel('Ratio')
plot(modeVarNoise(startNum:fitNum)./modeVar(startNum:fitNum),'b');
hold off


% plot mode varience autocorrelations
subplot(2,2,2);
title('Autocorralations');
xlabel('Frame Lag')
ylabel('Autocorrelation')
cc = jet(size(modeAmp,1));
for j=startNum:fitNum
    ac1=autocorr(modeAmp(j,:),int64(size(modeAmp(j,:),2)/2));
    hold on;
    plot(ac1);
    hold off;
    legendlabel{j}=num2str(j);
end
legend(legendlabel)


% plot sparce sampling varience by number of skipped frames TODO varrify operation
subplot(2,2,3);
title('Varience with Sparce Sampling');
xlabel('Frame Lag');
ylabel('Varience');
sampleVar=zeros(size(modeAmp,1),floor(size(modeAmp,2)/2));
for j=1:size(sampleVar,1)
    for i=1:size(sampleVar,2)
        sample=[];
        for k=1:floor(size(modeAmp,2)/i)
            sample(k)=modeAmp(j,i*k);
        end
        sampleVar(j,i)=var(sample);
    end
end
for j=1:size(sampleVar,1)
    hold on;
    plot(sampleVar(j,:))
    hold off;
end


% plot fits (see plotfit.m)
subplot(2,2,4);
hold on;
% raw data
t=double(startNum:fitNum);
plot(t,modeVar1(startNum:fitNum),'-Ob');
% point wise estimation
plot(t,k_B*Temperature*2*mean(LengthAtTime)/(mean(EI)*pi^2)./t.^2,'-r','LineWidth',2);
% linear, 1 param models
plot(t,1./f1(t).^2,'-y','LineWidth',2)
plot(t,1./(mean(var_2)/mean(startNum:fitNum).*t).^2,'-g','LineWidth',2)
% linear, 2 param
plot(t,1./f2(t_1),'-b','LineWidth',2)
plot(t,1./((q4-q2*q1/q0)/(q3-q1^2/q0).*t_1+(q2-(q4-q2*q1/q0)/(q3-q1^2/q0)*q1)/q0),'-p','LineWidth',2)
xlabel('Mode Number')
ylabel('var(a_n) (rad) ')
legend('raw','pointwise','1 param lin w/ int','1 param lin w/o int', '2 param lin w/o weights','2 param lin w/ weights');
