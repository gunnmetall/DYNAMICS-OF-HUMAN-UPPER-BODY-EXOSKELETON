clear all;

%lopa
load dataframe_x.mat
load dataframe_y.mat

load FINAL_PAYLOAD_X.mat
load FINAL_PAYLOAD_Y.mat

model_EMG=fitlm(df,DATFRAME_Y);

model_PAYLOAD=fitlm(FINAL_PAYLOAD_X,FINAL_PAYLOAD_Y);

prompt="enter payload";
payload(1)=input(prompt);
payload=zeros(1,21);

for i=2:21
    payload(i)=payload(i-1);
end

a = arduino('com10','uno');
imu1 = mpu6050(a);

b = arduino('com9','uno');
imu2 = mpu6050(b);

ans(1) = 0;
dt = 1;
ts = 20;
t = 0:dt:ts;
l1=0.5;
l2=0.5;
theta(1) = 0;
Theta(1) =0;

for i = 1:length(t)
    gyroReadings1 = readAngularVelocity(imu1);
    gyroReadings2 = readAngularVelocity(imu2);
    theta(i+1) = theta(i) + 1*gyroReadings1(2)*dt;
    Theta(i+1) = Theta(i) + 0.95*gyroReadings2(2)*dt;
    
    subplot(3,2,1);
    plot(t(1:i),theta(1:i),'LineWidth',2)
    title("Variation of θ_1 in -\pi to \pi wrt time")
    xlabel('time t')
    ylabel("θ_1")
    axis([-10,10,-3,3])

    subplot(3,2,3);
    plot(t(1:i),Theta(1:i),'LineWidth',2)
    title("Variation of θ_2 in -\pi to \pi wrt time")
    xlabel('time t')
    ylabel("θ_2")
    axis([-10,10,-3,3])

    th1(i)= 65*Theta(i)- 90;
    th2(i)= 65*theta(i) -90;
    l1_x(i)= l1*cosd(th1(i));
    l1_y(i)=l1*sind(th1(i));
    l2_x(i)=l1*cosd(th1(i))+l2*cosd(th2(i));
    l2_y(i)=l1*sind(th1(i))+l2*sind(th2(i));

    subplot(3,2,2);
    plot([0 l1_x(i) l2_x(i)],[0 l1_y(i) l2_y(i)],'LineWidth',2)
    title("Calibrated motion oh upper limb")
    grid on
    axis([-1 1 -1 1]);

    ans(i) = readVoltage(a, 'A1');
    
    subplot(3,2,4);
    plot(t(1:i),ans(1:i),'LineWidth',2);
    title("Variation of muscle stress wrt time")
    xlabel("time t")
    ylabel("Electrical Signals")

    subplot(3,2,5);
    X(1)=i;
    X(2)=th1(i);
    X(3)=th2(i);
    X(4)=ans(i);
    Time(i)=i;
    PAY_LOAD(i)=payload(i);
    y_pred(i) = predict(model_EMG,X);
    plot(t(1:i),y_pred(1:i),'LineWidth',2,color="g");
    hold on
    plot(t(1:i),ans(1:i),'LineWidth',2,color="b");
    title("Predicted EMG vs Observed EMG")
    xlabel("time t")
    ylabel("Electrical Signals")
    legend("Predicted","Observed");
    hold off

    subplot(3,2,6);
    title("Predicted Payload vs Observed Payload")
    xlabel("time t")
    ylabel("Payload")
    plot(t(1:i),payload(1:i),'LineWidth',2)
    pause(dt)
end

aa=[]
aa=horzcat(aa,th1);
aa=horzcat(aa,th2);
aa=horzcat(aa,payload);
ypred2 = predict(model_PAYLOAD,aa)

