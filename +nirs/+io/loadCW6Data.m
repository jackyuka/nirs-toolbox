function data = loadCW6Data( filenames )

    % if a single filename, put it in a cell
    if ischar( filenames )
        filenames = {filenames};
    end
    
    % iterate through cell array
    for iFile = 1:length(filenames)
        
        % load data as a struct
        d = load( filenames{iFile}, '-mat' );
        
        % put into data class
        tData = nirs.FunData();
        tData.description = filenames{iFile};
        
        try        
            nTime = length(d.t);

            % data
            if size(d.d,1) == nTime
                tData.data = d.d;
            elseif size(d.d,2) == nTime
                tData.data = d.d.';
            else
                error('Data length and time vector don''t match in size.')
            end

            % time vector
            tData.time = d.t(:);

            % probe
            tData.probe = nirs.util.sd2probe( d.SD );
            [tData.probe.link, idx] = ...
                sortrows(tData.probe.link,{'type','source','detector'});

            tData.data = tData.data(:,idx);

            if isfield(d,'StimDesign')
                names = {};
                for iStim = 1:length(d.StimDesign)
                    if isfield(d.StimDesign,'cond')
                        names{end+1} = d.StimDesign(iStim).cond;
                    else
                        names{end+1} = d.StimDesign(iStim).name;
                    end
                end
                names = unique(names,'stable');

                stims = Dictionary();
                for iStim = 1:length(names)
                    stims(names{iStim}) = nirs.design.StimulusEvents();
                end

                for iStim = 1:length(d.StimDesign)
                    if isfield(d.StimDesign,'cond')
                        name = d.StimDesign(iStim).cond;
                    else
                        name = d.StimDesign(iStim).name;
                    end

                    thisStim = stims(name);
                    thisStim.name = name;
                    thisStim.onset = [thisStim.onset(:); d.StimDesign(iStim).onset(:)];
                    thisStim.dur = [thisStim.dur(:); d.StimDesign(iStim).dur(:)];
                    thisStim.amp = [thisStim.amp(:); d.StimDesign(iStim).amp(:)];

                    stims(name) = thisStim;
                end

                tData.stimulus = stims;
            end

            % demographics for group level
            if isfield(d,'demographics')
                for i = 1:length(d.demographics)
                    name = d.demographics(i).name;
                    value = d.demographics(i).value;
                    tData.demographics(name) = value;
                end
            end
            
        catch err
            warning(err.message)
        end
        
        % append to list of data
        data(iFile) = tData;
    end


end

