export ENV_GROUPS_BASE_DIR="$HOME/.config/env-groups"
#create_env_group mygroup $HOME/my-env/dir

#allow stuff like 
#env_group create ...
#env_group delete ...
#env_group $group add ...
#env_group $group remove ...
#env_group $group load
env_group() {

}

env_group_create() {
    local group=$1
    shift;
    local group_cfg_dirs=( "$@" )
    local group_dir="$ENV_GROUPS_BASE_DIR/$group"
    mkdir -p $group_dir
    touch $group_dir/dirs
    printf "%s\n" ${group_cfg_dirs[@]} > $group_dir/dirs
    touch $group_dir/envfile
    echo "env group $group created for directories: $group_cfg_dirs"
}

#env_group_add KEY1=VALUE1 KEY2=VALUE2 ....
env_group_add() {
    local group=$1
    local env_file="$ENV_GROUPS_BASE_DIR/$group/envfile"
    shift;
    local group_envs=( "$@" )
      for envkeyval in "${group_envs[@]}"; do
        IFS="="
        parts=("${(@s/=/)envkeyval}")
        key=${parts[1]}
        value=$(printf "=%s" ${parts[@]:1})
        value=${value:1}

        env_line="$key=$value"
        echo ${env_line} >> $env_file
        unset IFS
      done
}

#env_group_remove 
env_group_remove() {
    local group=$1
    local env_file="$ENV_GROUPS_BASE_DIR/$group/envfile"
    shift
    local envs_to_remove=("$@")

    for env_name in "${envs_to_remove[@]}"; do
        sed -i "/^$env_name=/d" "$env_file"
    done
    #rm "$env_file.bak" true
}

#load_env_group mygroup
env_group_load() {
    local group=$1
    local env_file="$ENV_GROUPS_BASE_DIR/$group/envfile"
    #https://github.com/direnv/direnv/blob/master/stdlib.sh
    #dotenv function
    awk '{ print "export", $0 }' $env_file > /tmp/$group.env
    source /tmp/$group.env
    rm /tmp/$group.env
}

env_group_unload() {
    local group=$1
    local env_file="$ENV_GROUPS_BASE_DIR/$group/envfile"

    awk '{ print "unset", $0 }' $env_file | awk -F= '{print $1}' > /tmp/$group.env
    
    source /tmp/$group.env    
    rm /tmp/$group.env
}