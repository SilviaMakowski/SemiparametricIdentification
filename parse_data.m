%parsing data to get the training and testing data according to the previous split
%also extracting the initial data point for each sentence of the training and testing
%besides counting the number data points for each individual for each type
function[train,ini_train,test, ini_test, individuals_types_count]=parse_data(all_data, train_ids,test_ids, types,desc)
    
    datapts_min_no=20; %minimum number of training data points allowed to specific individual and type

    individuals_points=all_data.y;
    individuals=unique(individuals_points);
    individual_number= size(individuals,1);
    
    test_sens=unique(all_data.senId(test_ids));
    train_sens=unique(all_data.senId(train_ids));

    test={};
    train={};
    ini_train={};
    ini_test={};
   

    all_train_data=downsample(all_data.X(find(train_ids),:),15);

    parfor individual = 1: individual_number %looping over all the individuals in the dataset
        individual_index=(individuals_points==individuals(individual));
        
        %collecting the training initial data points 
        ini_train_id={};ini_train_id{1}=[];ini_train_id{2}=[];
        for train_sen=train_sens' 
            train_sen_index=(all_data.senId==train_sen);
            train_temp=all_data.X(min(individual_index,train_sen_index),:);
            if(size(train_temp,1)>0)
                ini_train_id{1}=[ini_train_id{1},train_temp(1,desc(1))];%amplitue
                ini_train_id{2}=[ini_train_id{2},train_temp(1,desc(2))];%duration
            end
        end
        ini_train{individual}=ini_train_id;
        

        %parsing the testing data into approperiate structure
        ini_test_id={};ini_test_id{1}=[]; ini_test_id{2}=[];
        test_sent_index=1;
        test_data={};
        for test_sen=test_sens' 
            test_sen_index=(all_data.senId==test_sen);
            test_data{test_sent_index}=all_data.X(min(individual_index,test_sen_index),:);
            if(size(test_data{test_sent_index},1)>0)
                ini_test_id{1}=[ini_test_id{1},test_data{test_sent_index}(1,desc(1))];%amplitude
                ini_test_id{2}=[ini_test_id{2},test_data{test_sent_index}(1,desc(2))];%duration
            end
            test_sent_index=test_sent_index+1;
        end
        ini_test{individual}=ini_test_id;
        test{individual}=test_data;

        
        
        %parsing the training data into approperiate structure
        train_data=all_data.X(min(individual_index,train_ids),:);
        
        %calculating the number of data points for each type
        %if the number is less than some threshold, a generalized data is assigned
        types_count=[];
        for type=types 
            types_count(type)=size(train_data(train_data(:,desc(5))==type,:),1);
            if types_count(type) < datapts_min_no %checking if the number of data points of specific type for specific individual is less that 20 data points
                % if so then use the generalised version of that type (aggregated data points of all individuals for a given type)
                train_data(train_data(:,desc(5))==type,:)=[];
                train_data=[train_data;abs(all_train_data(all_train_data(:,desc(5))==type,:))];
            end

        end
        individuals_types_count(individual,:)=types_count;
        train{individual}=train_data; 

    end
end
