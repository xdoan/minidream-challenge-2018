function [submission, submit_url] = submit_module_answers(answers)
% submit_module_answers Submit answers to Synapse
[session, username] = syn_login();
submit_entity_id = find_submit_file(session, username);

entity_annots = get_annotations(session, submit_entity_id);

submission = update_annotations(session, entity_annots, answers);
submit_url = strcat('https://www.synapse.org/#!Synapse:', submit_entity_id);
% disp('Go here to find the file with your submitted answers:');
% disp(submit_url);
% disp(' ');
% disp('Click on "Tools" -> "Submit File to Challenge" and select');
% disp('**2018 mini-DREAM evaluation**');
% disp('(after clicking "Next", select to submit as an individual)');

end


function [session, username] = syn_login()
% syn_login Login to Synapse

options = weboptions('MediaType', 'application/json');
auth_endpoint = 'https://repo-prod.prod.sagebase.org/auth/v1/session';

values = inputdlg({'Synapse Username:', 'Synapse Password:'});
user_data = struct('email', values{1}, 'password', values{2});
username = values{1};
session = webwrite(auth_endpoint, user_data, options);
end

function entity_id = find_submit_file(session, username)
% find_submit_file Find the file that matches the Synapse username
options = weboptions( ...
    'HeaderFields', {'sessionToken', session.sessionToken}, ...
    'MediaType', 'application/json' ...
);
repo_endpoint = 'https://repo-prod.prod.sagebase.org/repo/v1/entity';
children_url = strcat(repo_endpoint, '/children');

submission_folder = 'syn14719311';
list_data = struct( ...
    'parentId', submission_folder, ...
    'includeTypes', {{'file'}} ...
);

submit_files = webwrite( ...
    children_url, ...
    list_data, ...
    options ...
);

for i = 1:numel(submit_files.page)
    if strmatch(username, submit_files.page(i).name)
        entity_id = submit_files.page(i).id;
        break
    end 
end
end


function entity_annotations = get_annotations(session, entity_id)
% get_annotations Retrieve annotations for a Synapse entity
options = weboptions( ...
    'HeaderFields', {'sessionToken', session.sessionToken}, ...
    'MediaType', 'application/json' ...
);

repo_endpoint = 'https://repo-prod.prod.sagebase.org/repo/v1/entity';
annots_url = strcat(repo_endpoint, '/', entity_id, '/annotations');

entity_annotations = webread(annots_url, options);
end


function entity_annotations = update_annotations(session, entity_annotations, data)
% update_annotations Update the Synapse entity annotations provided based
%   on the input data
options = weboptions( ...
    'HeaderFields', {'sessionToken', session.sessionToken}, ...
    'MediaType', 'application/json', ...
    'RequestMethod', 'put' ...
);

repo_endpoint = 'https://repo-prod.prod.sagebase.org/repo/v1/entity';
annots_url = strcat(repo_endpoint, '/', entity_annotations.id, '/annotations');

yaml_data = struct('yaml', {{YAML.dump(data)}});
entity_annotations.stringAnnotations = yaml_data;

entity_annotations = webwrite( ...
    annots_url, ...
    jsonencode(entity_annotations), ...
    options ...
);
end