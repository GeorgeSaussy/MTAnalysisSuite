%{
    plotfit.m
    @purpose calculate mode varience fits with various fitting modes
    @version 0.8.4
    @author George Saussy
%}


h1=figure;
t=double(startNum:fitNum);


%{
    Compute EI for each mode independently
    Gittes method for comparison
    No length dependence
%}
EI=(k_B*Temperature*2*mean(LengthAtTime)/pi^2./modeVar1(startNum:fitNum)./(startNum:fitNum).^2)';
subplot(2,2,1)
hold on
plot(startNum:fitNum,EI,'o')
xlabel('Mode Number')
ylabel('EI  (N m^2)')
EI_point    = mean(EI)
var_EI_point  = var(EI)
C={'EI_{mean} = ',num2str(mean(EI)),' +/- ',num2str(sqrt(var_EI_point))};
title(strjoin(C, ''));



% one parameter fits i.e. fitting all modes simultaniously with no length dependence
% fit paramteter with intercept
var_2=[];for i=startNum:fitNum;var_2(i-startNum+1)=double(1/sqrt(modeVar1(i)));end 
d=[];for i=startNum:fitNum;d(i-startNum+1)=double(delta_modeVar1(i)/2/sqrt(modeVar1(i)^3));end
f1 = fit(t',var_2','poly1');
EI_int = (f1.p1)^2*k_B*Temperature*2*mean(LengthAtTime)/pi^2 
% fit parameter with out intercept, forced
q0=fitNum-startNum+1;
q1=sum(startNum:fitNum);
q3=sum((startNum:fitNum).^2);
var_EI_int=(q0*sum((startNum:fitNum).*d)+q1*sum(d))/(q0*q3-q1^2)*(f1.p1)*k_B*Temperature*2*mean(LengthAtTime)/pi^2
EI_noint = (sum(var_2.*(startNum:fitNum))/sum((startNum:fitNum).^2))^2*k_B*Temperature*2*mean(LengthAtTime)/pi^2
var_EI_noint=(sum((startNum:fitNum).*d)/sum((startNum:fitNum).^2))*(sum(var_2.*(startNum:fitNum))/sum((startNum:fitNum).^2))*k_B*Temperature*2*mean(LengthAtTime)/pi^2
subplot(2,2,2);
hold on;
plot(t,modeVar1(startNum:fitNum),'-Ob');
plot(t,1./f1(t).^2,'-g','LineWidth',2)
plot(t,1./(mean(var_2)/mean(startNum:fitNum).*t).^2,'-r','LineWidth',2)
legend('Data','Lin Fit w/ Int.', 'Lin Fit w/o Int.');
xlabel('Mode Number')
ylabel('var(a_n) (rad)')
title(['          EI_{int} = ' num2str(EI_int,'%1.3e') ' (N m^2)' '      EI_{no int} = ' num2str(EI_noint, '%1.3e') ' (N m^2)'])


% two parameter fits i.e. fitting all modes simultaniously with length dependence
% without weights
t_1   = t.^2;
var_1=[];for i=startNum:fitNum;var_1(i-startNum+1)=double(1/(modeVar1(i)));end % TODO verify
d=[];for i=startNum:fitNum;d(i-startNum+1)=double(delta_modeVar1(i)/modeVar1(i)^2);end
w=[];for i=startNum:fitNum;w(i-startNum+1)=1/d(i-startNum+1);end;
f2 = fit(t_1',var_1','poly1');
A_noweight = (f2.p1*mean(LengthAtTime)*k_B*Temperature*2)/pi^2
std_A_noweight=(q0^2*sum(t_1.^2.*d.^2)+q1^2*sum(d.^2))^0.5/(q0*q3-q1^2)*k_B*mean(LengthAtTime)*Temperature*2/pi^2
B_noweight = (f2.p2*k_B*Temperature/mean(LengthAtTime))
std_B_noweight=(sum(d.^2)+q1*std_A_noweight^2)^0.5/q0*k_B*Temperature/mean(LengthAtTime)
% with weights
q0=sum(w);
q1=sum(w.*t_1);
q2=sum(w.*var_1);
q3=sum(w.*t_1.^2);
q4=sum(w.*t_1.*var_1);
A_weight=((q4-q2*q1/q0)/(q3-q1^2/q0)*mean(LengthAtTime)*k_B*Temperature*2)/pi^2
std_A_weight=(q0^2*sum(w.^2.*t_1.^2.*d.^2)+q1^2*sum(w.^2.*d.^2))^0.5/(q0*q3-q1^2)*mean(LengthAtTime)*k_B*Temperature*2/pi^2
B_weight=((q2-(q4-q2*q1/q0)/(q3-q1^2/q0)*q1)/q0*k_B*Temperature/mean(LengthAtTime))
std_B_weight=(sum(d.^2.*w.^2)+q1^2*std_A_noweight^2)^0.5/q0*k_B*Temperature/mean(LengthAtTime)
subplot(2,2,3)
hold on
plot(t,f2(t_1),'-g','LineWidth',2)
plot(t,(q4-q2*q1/q0)/(q3-q1^2/q0).*t_1+(q2-(q4-q2*q1/q0)/(q3-q1^2/q0)*q1)/q0,'-b','LineWidth',2)
plot(t, var_1,'-Ob')
legend('Lin Fit w/o weights','Lin Fit w/ weights','Data')
title(['          EI = ' num2str(A_noweight,'%1.3e') ' (N m^2)' '      B = ' num2str(B_noweight, '%1.3e') ' (N)'])
xlabel('Mode Number')
ylabel('1/(Variance ( a_n))^{1/2} (1/ \mum )^{1/2} ')


% Plotting Everything
subplot(2,2,4)
hold on;
% raw data
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
