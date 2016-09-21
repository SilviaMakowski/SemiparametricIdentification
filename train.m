function[individual_model_seed, duration_scale_seed, amplitude_scale_seed] =train(types, train_seed, initial_train_seed, train_data,dataSubset ,iterations_number,iter_no, sample_no, amp_res,dur_res, model_name, desc, alpha)
	explore_alpha=false;
    if nargin < 13
        explore_alpha=true;
    end
    alpha_values=[1,10,100];
    
 
	for seed=1:iterations_number		
        all_data=train_data{seed};
		%calculating parameters needed for train
        
        if (explore_alpha)
            alpha=estimate_alpha(all_data,ones(1,length(all_data.senId)),alpha_values,seed,types,desc);
            disp(['Iteration:', num2str(seed),' Choosen alpha= ',num2str(alpha)]);
        end
        sampled_train=downsample(all_data.X,15);
        [amplitude_scale,duration_scale]=estimate_sigma(sampled_train(:,desc(1)),sampled_train(:,desc(2)));
        
		
		%training a model for the given training data with specific parametes
		
        individual_model=train_model(train_seed{seed},initial_train_seed{seed},amplitude_scale,duration_scale,alpha,amp_res,dur_res, iter_no,sample_no, desc, types, seed);
        
		
		
		
        %saving the results of this split/seed
		
		individual_model_seed{seed}=individual_model;
		duration_scale_seed{seed}=duration_scale;
        amplitude_scale_seed{seed}=amplitude_scale;
		
	end
	%saving the processing result and trained models
    %save(model_name,'individuals_types_count_seed','types','initial_test_seed','data_index');
end

%%estimate the amplitude and duration kernel sigma values
function[amplitude_scale,duration_scale] =estimate_sigma(amplitude_list,duration_list)
   amplitude_scale=0;
   duration_scale=0;
   for h=1:length(amplitude_list)
       for k=h+1:length(amplitude_list)
          amplitude_scale=amplitude_scale+abs(amplitude_list(h)-amplitude_list(k));
          duration_scale=duration_scale+abs(duration_list(h)-duration_list(k));
       end
   end
   amplitude_scale=2*amplitude_scale/(length(amplitude_list))^2;
   duration_scale=2*duration_scale/(length(amplitude_list))^2;
end


%%estimate the amplitude/duration kernel alpha value
function[alpha]=estimate_alpha(all_data,train_ids,alpha_values,seed,types,desc)
    selected_ids=split_data(all_data.senId,train_ids,seed);
    area_resolution=500;%number of points to calculate area
    max_ampl=100;
    amp_res=(0:(log(max_ampl+2)/(area_resolution)):log(max_ampl+2))';
    dur_res=(0:(1000/(area_resolution)):1000)';
    acc_values=[];
	seed_no=5;
	model_name='temp_result';
    result_file='users_likelihoods';%name of the likelihoods files containing the probability of each dataset to be one of the users
    for alpha_value=alpha_values
        [train_data_seed, test_data_seed,train_seed, test_seed, initial_train_seed,initial_test_seed,individuals_types_count_seed]=process_data(all_data,selected_ids,seed_no, types, desc);
        [individual_model_seed, duration_scale_seed, amplitude_scale_seed]=train(types, train_seed, initial_train_seed, train_data_seed,selected_ids,seed_no,1000, 500, amp_res, dur_res,model_name,desc,alpha_value);
        acc_values=[acc_values;identify(1,result_file, amp_res,dur_res,types,test_seed,initial_test_seed, individual_model_seed, individuals_types_count_seed)];
    end
    [v,i]=max(acc_values);
    alpha=alpha_values(i);
end
