load('251r_data') %load eye movements data (available upon request)
area_resolution=1000;%number of points to calculate area
sampling_iterations=10000;%number of samples
burnin_iterations=5000;%number of considered samples
selected_data=ones(1,length(user_data.senId));%selected all the data points
model_name='semiparametric_model';%name of the trained model, saved as a mat file after training
result_file='users_likelihoods';%name of the likelihoods files containing the probability of each dataset to be one of the users
seed_no=10; %number of iterations to average over
train(user_data,selected_data,seed_no,sampling_iterations, burnin_iterations, area_resolution,model_name); %training the model and processing the data
identify(model_name, 1,result_file);%identifying the users generating the test datasets