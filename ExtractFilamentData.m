function[FilamentData] = ExtractFilamentData1(Objects, Config)          
%%% Modify Filament using the values from Objects.raw
        %clearvars -except Objects Config
        PixSize = Config.PixSize;
        FilamentRaw={};
        for i = 1:size(Objects,2)
            var=[];
            if isempty(Objects {1,i})
            else
             % Deterine the right filament
                sr=[];
                for kr=1: size(Objects{1,i}.raw,2);
                    sr(kr)=size(Objects{1,i}.raw{kr},2);
                end
                [a1 b1]=max(sr); % Choose the one with the most entries (20)
                for j = 1:size(Objects{1,i}.raw{b1},2)
                    var=[var;...
                        PixSize .* Objects{1,i}.raw{b1}(1,j).x.value PixSize .* Objects{1,i}.raw{b1}(1,j).x.error...        % Position
                                   Objects{1,i}.raw{b1}(1,j).o.value            Objects{1,i}.raw{b1}(1,j).o.error...        % Tangent Angle
                                   Objects{1,i}.raw{b1}(1,j).h.value            Objects{1,i}.raw{b1}(1,j).h.error...        % Intensity
                        PixSize .* Objects{1,i}.raw{b1}(1,j).w.value PixSize .* Objects{1,i}.raw{b1}(1,j).w.error...        % Width
                        %Objects{1,i}.raw{1,b}(1,j).b.value Objects{1,i}.raw{1,b}(1,j).b.error...
                        %Objects{1,i}.raw{1,b}(1,j).r.value Objects{1,i}.raw{1,b}(1,j).r.error...  
                        ];       
                end
            end
            FilamentRaw{i} = var;
            clear var
        end
        for i = 1:size(Objects,2)
            if isempty(Objects{1,i})
                a(i) = 0;
            else
                a(i) = size(FilamentRaw{1,i}(:,1),1);
            end
        end
        [c d] = hist(a(1,:));
        [t s] = max(c);
        clear c; clear t;
        expected = d(s);
        logic = a > expected / 2;
        FilamentRaw(find(a < expected / 2)) = {[]};
        FilamentData = struct;
        FilamentData.Config = Config;
        FilamentData.Data = FilamentRaw;
        %clearvars -except FilamentData Config Objects
        return 
   
end
