function[train_data_seed, test_data_seed, train_seed, test_seed, initial_train_seed,initial_test_seed,individuals_types_count_seed] =process_data(all_data,dataSubset ,iterations_number, types, desc)
 
    for seed=1:iterations_number
        
        %splitting the data randomly with specific seed
        [train_ids,test_ids]=split_data(all_data.senId,dataSubset,seed);
        
        %parsing data to get the training and testing data according to the previous split
        %also extracting the initial data point for each sentence of the training and testing
        %besides counting the number data points for each individual for each type
        [train,initial_train, test, initial_test, individuals_types_count]=parse_data(all_data, train_ids,test_ids, types,desc);
                
        %saving the results of this split/seed
        train_data_seed{seed}.X=all_data.X(train_ids,:);
        train_data_seed{seed}.senId=all_data.senId(train_ids);
        train_data_seed{seed}.y=all_data.y(train_ids);
        
        test_data_seed{seed}.X=all_data.X(test_ids,:);
        test_data_seed{seed}.senId=all_data.senId(test_ids);
        test_data_seed{seed}.y=all_data.y(test_ids);
        
        
        test_seed{seed}=test;
		train_seed{seed}=train;
		test_seed{seed}=test;
        initial_test_seed{seed}=initial_test;
        initial_train_seed{seed}=initial_train;
        individuals_types_count_seed{seed}=individuals_types_count;
    end
end