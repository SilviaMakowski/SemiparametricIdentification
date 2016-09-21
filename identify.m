%calculates likelihood of each user being any other user using a percentage of the test data and saving the result into users_likelihood_file 
function[acc] =identify(percentage, users_likelihood_file, amp_res,dur_res,types,test_seed,initial_test_seed, individual_model_seed, individuals_types_count_seed)

 duration_cindex=2;
    amplitude_cindex=3;
	lowrang_cindex=4;
	highrang_cindex=5;
    type_cindex=1;
    data_index=[amplitude_cindex,duration_cindex,lowrang_cindex,highrang_cindex,type_cindex];

    %load(training_model);
    save_result=true;
    if nargin < 3
        save_result=false;
    end
    %amp_res=amp_res;
    %dur_res=dur_res;
    %types=types;
    likelihood_values={};
    acc_list=[];
    iterations_number=length(individual_model_seed);
    for seed=1:iterations_number %for each training iteration
        iteration_error=0;
        individual_model=individual_model_seed{seed};
        test=test_seed{seed};
        initial_pts=initial_test_seed{seed};
        %initial_train_pts=initial_train_seed{seed};
        individuals_types_count=individuals_types_count_seed{seed};
        individual_number=length(individual_model);
        likvalues=zeros(individual_number,individual_number);

        parfor id = 1: individual_number %for each individual in the test
            likv=zeros(1,individual_number);
            rng(seed);
            cached_test=cat(1,test{id}{1:round(length(test{id})*(percentage))});
            ini_amp=initial_pts{id}{1}(1:round(length(initial_pts{id}{1})*(percentage)));
            ini_dur=initial_pts{id}{2}(1:round(length(initial_pts{id}{2})*(percentage)));
            test_data=[];
            for type=types
                test_data(1,type).data=abs(cached_test(cached_test(:,data_index(5))==type,data_index(1)));
                test_data(2,type).data=abs(cached_test(cached_test(:,data_index(5))==type,data_index(2)));
                test_data(3,type).data=abs(cached_test(cached_test(:,data_index(5))==type,data_index(3)));
                test_data(4,type).data=abs(cached_test(cached_test(:,data_index(5))==type,data_index(4)));
            end

            maxlh=-inf;
            maxid=-1;

            for individual=1:individual_number %for each individual training model
                points_number=sum(individuals_types_count(individual,:))+1;%+length(initial_train_pts{individual});
                value=0;

                %for each type calculate the likelihood based on the amplitude and duration distribution
                for type=types
                    value=value+log((individuals_types_count(individual,type)+1)/points_number)*(size(test_data(1,type).data,1)); 
                    value=value+data_lik(test_data(1,type).data,amp_res,individual_model(individual).type(type).amplitude,[test_data(3,type).data,test_data(4,type).data]);
                    value=value+data_lik(test_data(2,type).data,dur_res,individual_model(individual).type(type).duration,0);    
                end
                
                %adding to the likelihood of the initial data points
                %value=value+log((length(initial_train_pts{individual})+1)/points_number)*(length(initial_pts{id}));
                value=value+data_lik(ini_amp',amp_res,individual_model(individual).type(6).amplitude,0);
                value=value+data_lik(ini_dur',dur_res,individual_model(individual).type(7).duration,0);

                if value > maxlh  %get the maximume likelihood          
                    maxlh=value;
                    maxid=individual;
                end
                likv(individual)=value;
            end
            likvalues(id,:)=likv; 
            if id ~= maxid
                iteration_error=iteration_error+1;
            end
        end
        likelihood_values{seed}=likvalues;
        acc_list(seed)=1-(iteration_error/individual_number);
    end
    acc=mean(acc_list);
    
    disp(['AVG Accuray= ' num2str(acc)]);
    if (save_result)
        save([users_likelihood_file '_' num2str(percentage*100)],'likelihood_values', 'acc_list');
    end
end