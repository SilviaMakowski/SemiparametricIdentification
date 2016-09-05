function[] =train(all_data,dataSubset ,iterations_number,iter_no, sample_no, resolution, model_name, alpha)
 

    explore_alpha=false;
    if nargin < 8
        explore_alpha=true;
    end
    
    alpha_values=[1,10,100];
    types=[1:1:5];
    max_ampl=100;
    
    %amplitude, duration, rang and type column index in the data
    duration_cindex=2;
    amplitude_cindex=3;
	lowrang_cindex=4;
	highrang_cindex=5;
    type_cindex=1;
    data_index=[amplitude_cindex,duration_cindex,lowrang_cindex,highrang_cindex,type_cindex];
    all_data.desc=data_index;

    for seed=1:iterations_number
        
        %splitting the data randomly with specific seed
        [train_ids,test_ids]=split_data(all_data.senId,dataSubset,seed);
        
        %calculating parameters needed for train
        if (explore_alpha)
            alpha=estimate_alpha(all_data,train_ids,alpha_values,seed);
            disp(['Iteration:', num2str(seed),' Choosen alpha= ',num2str(alpha)]);
        end
        sampled_train=downsample(all_data.X(find(train_ids),:),15);
        [amplitude_scale,duration_scale]=estimate_sigma(sampled_train(:,all_data.desc(1)),sampled_train(:,all_data.desc(2)));
        amp_res=(0:(log(max_ampl+2)/(resolution)):log(max_ampl+2))';
        dur_res=(0:(1000/(resolution)):1000)';
    
        
        %parsing data to get the training and testing data according to the previous split
        %also extracting the initial data point for each sentence of the training and testing
        %besides counting the number data points for each individual for each type
        [train,initial_train, test, initial_test, individuals_types_count]=parse_data(all_data, train_ids,test_ids, types);
                
        %training a model for the given training data with specific parametes
        individual_model=train_model(train,initial_train,amplitude_scale,duration_scale,alpha,amp_res,dur_res, iter_no,sample_no, data_index, types, seed);
        
        %saving the results of this split/seed
        individual_model_seed{seed}=individual_model;
        test_seed{seed}=test;
        duration_scale_seed{seed}=duration_scale;
        amplitude_scale_seed{seed}=amplitude_scale;
        individuals_types_count_seed{seed}=individuals_types_count;
        initial_test_seed{seed}=initial_test;
        initial_train_seed{seed}=initial_train;
    end
    
    %saving the processing result and trained models
    save(model_name,'individual_model_seed','test_seed','amp_res', 'dur_res','iterations_number','individuals_types_count_seed','types','initial_test_seed','data_index');
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
function[alpha]=estimate_alpha(all_data,train_ids,alpha_values,seed)
    selected_ids=split_data(all_data.senId,train_ids,seed);
    acc_values=[];
    for alpha_value=alpha_values
        train(all_data,selected_ids,5,1000, 500, 500,'temp_result',alpha_value);
        acc_values=[acc_values;identify('temp_result', 1)];
        delete('temp_result');
    end
    [v,i]=max(acc_values);
    alpha=alpha_values(i);
end