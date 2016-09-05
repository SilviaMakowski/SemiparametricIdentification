 %training a model for the given training data with specific parametes
function[individual_model]=train_model(train,ini_data,amp_sigma, dur_sigma, alpha, amp_res, dur_res, iter_no, iter_burnin_no, data_index, types, seed)
    individual_model=[];
    parfor id = 1: length(train) %loop over all the individuals
        rng(seed);
        data=train{id};
        for type=types %loop over all the data points' types
            %fitting a model for the amplitude of specific individual and specific type
            individual_model(id).type(type).amplitude=fit_dist(abs(data(data(:,data_index(5))==type,data_index(1))),amp_res,alpha,amp_sigma, iter_no, iter_burnin_no,[data(data(:,data_index(5))==type,data_index(3)),data(data(:,data_index(5))==type,data_index(4))]);
            %fitting a model for the duration of specific individual and specific type
            individual_model(id).type(type).duration=fit_dist(abs(data(data(:,data_index(5))==type,data_index(2))),dur_res,alpha,dur_sigma, iter_no, iter_burnin_no,0);
        end
        %fitting a model for the amplitude initial data points of specific individual
        individual_model(id).type(6).amplitude=fit_dist(ini_data{id}{1}',amp_res,alpha,amp_sigma, iter_no, iter_burnin_no,0);
        %fitting a model for the duration initial data points of specific individual
        individual_model(id).type(7).duration=fit_dist(ini_data{id}{2}',dur_res,alpha,dur_sigma, iter_no, iter_burnin_no,0);
    end
end
