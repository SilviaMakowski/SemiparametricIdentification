load('251r_data') %load eye movements data (available upon request)
% user_data.X contains list of eye fixations, each fixation record have 5 attributes
% attr 1: type 1:5
% attr 2: duration
% attr 3: log amplitude
% attr 4: min range of amplitude
% attr 5: max range of amplitude
% user_data.y contains list of individuals' ids representing the owners of the corresponding fixation row in user_data.X
% user_data.senId contains the sentence id from which the corresponding fixation was generated

area_resolution=1000;%number of points to calculate area
sampling_iterations=10000;%number of samples
burnin_iterations=5000;%number of considered samples
selected_data=ones(1,length(user_data.senId));%selected all the data points
model_name='semiparametric_model';%name of the trained model, saved as a mat file after training
result_file='users_likelihoods';%name of the likelihoods files containing the probability of each dataset to be one of the users
seed_no=10; %number of iterations to average over


max_ampl=100;
amp_res=(0:(log(max_ampl+2)/(area_resolution)):log(max_ampl+2))';
dur_res=(0:(1000/(area_resolution)):1000)';
types=[1:1:5];
%amplitude, duration, rang and type column index in the data
duration_cindex=2;
amplitude_cindex=3;
lowrang_cindex=4;
highrang_cindex=5;
type_cindex=1;
data_index=[amplitude_cindex,duration_cindex,lowrang_cindex,highrang_cindex,type_cindex];
%user_data.desc=data_index;
max_ampl=100;
amp_res=(0:(log(max_ampl+2)/(area_resolution)):log(max_ampl+2))';
dur_res=(0:(1000/(area_resolution)):1000)';

                           
[train_data_seed, test_data_seed,train_seed, test_seed, initial_train_seed,initial_test_seed,individuals_types_count_seed]=process_data(user_data,selected_data,seed_no, types, data_index); %training the model and processing the data
individual_model_seed=train(types, train_seed, initial_train_seed, train_data_seed,selected_data,seed_no,sampling_iterations, burnin_iterations, amp_res,dur_res,model_name,data_index);
acc=identify(1,result_file, amp_res,dur_res,types,test_seed,initial_test_seed, individual_model_seed, individuals_types_count_seed);