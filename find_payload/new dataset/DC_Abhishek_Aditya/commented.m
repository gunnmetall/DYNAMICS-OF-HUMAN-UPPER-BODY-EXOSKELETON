clear all;
clc;

% loading the datasets
load FINAL_PAYLOAD_X.mat
load FINAL_PAYLOAD_Y.mat

load data_x_emg_0.mat
load data_x_emg_2.mat
load data_x_emg_5.mat
load data_y_emg_0.mat
load data_y_emg_2.mat
load data_y_emg_5.mat

% training and fitting the model to presict the EMG
model_EMG_0=fitlm(data_x_emg_0,data_y_emg_0);
model_EMG_2=fitlm(data_x_emg_2,data_y_emg_2);
model_EMG_5=fitlm(data_x_emg_5,data_y_emg_5);

% training and fitting the model to presict the Payload
model_PAYLOAD=fitlm(FINAL_PAYLOAD_X,PAYLOAD_Y);

% taking user input for payload
prompt="enter payload = ";
payload=input(prompt);

%making arduino and sensor object
arduino_1 = arduino('com10','uno');
imu1 = mpu6050(arduino_1);
arduino_2 = arduino('com9','uno');
imu2 = mpu6050(arduino_2);

% initializing the variables
EMG(1) = 0;
dt_1 = 1;
ts_1 = 20;
t = 0:dt_1:ts_1;
l1=0.5;
l2=0.5;
theta(1) = 0;
Theta(1) =0;

% iterating for 20 seconds
for i = 1:length(t)
    gyroReadings1 = readAngularVelocity(imu1);
    gyroReadings2 = readAngularVelocity(imu2);
    theta(i+1) = theta(i) + 1*gyroReadings1(2)*dt_1;
    Theta(i+1) = Theta(i) + 0.95*gyroReadings2(2)*dt_1;
    

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

    % storing the thetas
    theta_1(i)= 65*Theta(i)- 90;
    theta_2(i)= 65*theta(i) -90;
    l1_x(i)= l1*cosd(theta_1(i));
    l1_y(i)=l1*sind(theta_1(i));
    l2_x(i)=l1*cosd(theta_1(i))+l2*cosd(theta_2(i));
    l2_y(i)=l1*sind(theta_1(i))+l2*sind(theta_2(i));

    % visualizing elbow angles
    subplot(3,2,2);
    plot([0 l1_x(i) l2_x(i)],[0 l1_y(i) l2_y(i)],'LineWidth',2)
    title("Calibrated motion oh upper limb")
    grid on
    axis([-1 1 -1 1]);

    % reading EMG signal
    EMG(i) = readVoltage(arduino_1, 'A1');
    
    % plotting EMG signal with respect to time
    subplot(3,2,4);
    plot(t(1:i),EMG(1:i),'LineWidth',2);
    title("Variation of muscle stress wrt time")
    xlabel("time t")
    ylabel("Electrical Signals")

    % making a dataset for our model to predict EMG
    X(1)=theta_1(i);
    X(2)=theta_2(i);
    X(3)=payload;
    Time(i)=i;

    % predicting the EMG signal for each second
    if payload==0
        y_pred(i) = predict(model_EMG_0,X);
    end

    if payload==2.5
        y_pred(i) = predict(model_EMG_2,X);
    end
    if payload==5
        y_pred(i) = predict(model_EMG_5,X);
    end
    % plotting predicted EMG vs the observed EMG
    subplot(3,2,5);
    plot(t(1:i),y_pred(1:i),'LineWidth',2,color="g");
    hold on
    plot(t(1:i),EMG(1:i),'LineWidth',2,color="b");
    title("Predicted EMG vs Observed EMG")
    xlabel("time t")
    ylabel("Electrical Signals")
    legend("Predicted","Observed");
    hold off
    pause(dt_1)

end

% making a dataset for our model to predict the payload
aa=[];
aa=horzcat(aa,theta_1);
aa=horzcat(aa,theta_2);
aa=horzcat(aa,EMG);

% displaying actual payload
print = sprintf('Actual Paylaod : %d Kg',payload);
disp(print);

% predicting the payload
ypred2 = predict(model_PAYLOAD,aa);
if ypred2<0
    ypred2=0;
end

% displaying predicted payload
print = sprintf('Predicted Paylaod : %d Kg',ypred2);
disp(print);


