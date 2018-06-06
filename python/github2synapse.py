#!/usr/bin/env python
import sys
import re
import requests
import synapseclient
from synapseclient import File


def create_synapse_link(syn, gh_item, parent_id):
    """

    """
    gh_file = File(
        path = gh_item['download_url'],
        name = gh_item['name'],
        parent = parent_id,
        synapseStore = False
    )
    return syn.store(gh_file)


def list_repo_contents(repo, dir_path):
    request = 'https://api.github.com/repos/{}/contents/{}'.format(
        repo, dir_path
    )
    return requests.get(request).json()


def filter_repo_contents(gh_items, pattern, field='name'):
    return [gh_i for gh_i in gh_items
            if re.search(pattern, gh_i[field])]


def main(argv):
    gh_repo = argv[0]
    gh_dir = argv[1]
    syn_dir = argv[2]
    filter_pattern = argv[3]

    syn = synapseclient.Synapse()
    syn.login()

    gh_items = list_repo_contents(gh_repo, gh_dir)
    gh_items = filter_repo_contents(gh_items, filter_pattern)
    for gh_i in gh_items:
        syn_file = create_synapse_link(syn, gh_i, syn_dir)
        print("Creating link to '{}' with entity '{}' in folder '{}'".format(
            gh_i['name'], syn_file['id'], syn_dir
        ))


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
