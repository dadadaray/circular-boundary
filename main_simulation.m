%% Times：2022/09/07
%% Author：Ye Tao
%% Function：Comparison between Linear Boundary and CBWF.

clc; clear all;

%% All paramenters

x_len = 100;
y_len = 100; % S \times S

x_ap_interval = 20.2;
y_ap_interval = 30.2; % AP interval

x_rp_interval = 20;
y_rp_interval = 20; % RP interval

sample_size = 2; % g

rfa = -4; % the path-loss exponent

[xy_ap] = Gen_ap(x_ap_interval,y_ap_interval,x_len,y_len);

beta = 0.5; % The difference transmit powers of APs

max_pd_range= -19; % max transmit power

min_pd_range = max_pd_range-beta * size(xy_ap,1); % min transmit power

%% Localization of CBWF
len_ap = size(xy_ap,1); 

pd = Gen_pd(len_ap,min_pd_range,max_pd_range); 

[xy_rp,rssi_rp,len_rp] = Gen_rp_rssi(x_rp_interval,y_rp_interval,x_len,y_len,rfa,xy_ap,pd,len_ap);

[same_x_y_ap] = Find_ap_coor(xy_ap);

[same_x_y_k,a_k,b_k,uncert_deg] = Cal_k(same_x_y_ap,rssi_rp,xy_ap,xy_rp);

[circle_point_r] = Cal_cir(same_x_y_ap,same_x_y_k,xy_ap);

[vir_rp] = Gen_vir(x_len,y_len,sample_size);

[vir_rp_ap_rank] = Gen_ap_rank(vir_rp,same_x_y_ap,circle_point_r);

T_test = 200; % The number of TPs

for i = 1:T_test
    xy_tp(i,:) = [x_len*rand,y_len*rand];
end

for i = 1:T_test
    [rssi_tp(i,:)] = Gen_tp_rssi(xy_tp(i,:),pd,xy_ap,rfa);
    [tp_ap_rank(i,:)] = Gen_tp_rank(rssi_tp(i,:),same_x_y_ap);
end

for i = 1:T_test 
    disp(i);
    [loc_est,loc_err] = Est_loc(tp_ap_rank(i,:),vir_rp_ap_rank,vir_rp,uncert_deg,xy_tp(i,:));
    loc_esta(i,:) = loc_est;
    recor(i) = loc_err;
end

figure;
plot(sort(recor),[1/T_test :1/T_test :1]);


%% Localization of Linear Boundary
[vir_line_rank] = Gen_ap_rank_line(vir_rp,same_x_y_ap,xy_ap); 

for i = 1:T_test 
    disp(i);
    [loc_est_line,loc_err_line] = Est_loc_line(tp_ap_rank(i,:),vir_line_rank,vir_rp,xy_tp(i,:));
    loc_esta_line(i,:) = loc_est_line;
    recor_line(i) = loc_err_line;
end

disp('the accuracy of CBWF:')
mean(recor) % accuracy of CBWF

disp('the accuracy of Linear Boundary:')
mean(recor_line) % accuracy of Linear Boundary

hold on;

plot(sort(recor_line),[1/T_test :1/T_test :1]);
legend('CBWF','Linear Boundary')


%% 绘制3D误差棒！
% close all;clear;clc;
% X = [5.35,0;5.03,0;4.95,0;5.03,0;4.68,0;4.92,0]; %(系列数据)
% E = [3.89,0;3.10,0;3.09,0;3.25,0;2.79,0;3.08,0];%（标准差）
% legends = {'CBWF'};%（图例）
% groupnames = cell(6,1);
% groupnames{1} = '6';groupnames{2} = '9';groupnames{3} = '15';groupnames{4} = '20';%（分组名称）
% groupnames{5} = '25'; groupnames{6} = '30';%（分组名称）
% Title = '';
% Xlabel = '\it{m}';
% Ylabel = 'Localization accuracy (m)';
% barweb(X,E,1,groupnames,Title,Xlabel,Ylabel,jet,'none',legends,2,'plot');
% legend('CBWF');
% box on;
% grid on;