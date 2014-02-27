function vssh() {
  ssh dev.noths.com "cd /var/sites/noths/development && $*"
}

function ttv() {
  dw=http://dw.notonthehighstreet.com/ttv-tracker/
  yesterday=$(date -j -v-1d +"%Y/%m/%d")
  open $dw$yesterday
}

function vssh() {
  ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current && $*"
}

function ds() {
  echo "You mean dqa."
}

function mds() {
  echo "you mean mdqa."
}

function force_mds() {
  echo "you mean force_mdqa"
}

function db() {
    u=;
    p=;
    h=;
    db=;
    options=;
    if [ $# -eq 0 ]; then
        u="-uroot";
        p="-proot";
        h="-h localhost";
        db="noths_development";
    else
        if [[ $1 =~ qa ]]; then
            u="-unoths";
            p="-pech7bav4viems4i";
            h="-h qa.hq.noths.com";
            db="noths_dump_20130222";
            num="${1/qa/}";
            if [ $((num)) -gt 9 ]; then
                options="-P330$num";
            else
                options="-P3300$num";
            fi;
        else
            if [ $1 == "prod" ]; then
                h="-h mysql-prod";
                db="noths_production";
                options="-A";
            else
                if [ $1 == "investigation" ]; then
                    u="-uroot";
                    p="-proot";
                    h="-h localhost";
                    db="investigation";
                else
                    echo "This is not the database you're looking for....";
                    return 1;
                fi;
            fi;
        fi;
    fi;
    echo "mysql $h $u $p $options $db";
    mysql $h $u $p $options $db
}

function dqa() {
  if [ -z "$1" ]; then
        echo "Please provide a staging environment number.";
        return;
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]] ; then
        exec >&2; echo "Invalid staging number.";
        return;
  fi

  remote_revision=$(ssh notonthehighstreet@qa$1.hq.noths.com 'cat /var/sites/notonthehighstreet/current/REVISION')
  current_revision=$(git log -1 --pretty=format:'%H')
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [ "$remote_revision" == "$current_revision" ]; then
        echo "Latest build already deployed."
  elif [ -z "$2" ]; then
            current_branch=$(git rev-parse --abbrev-ref HEAD)
            echo "Deploying $current_branch"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                             bundle exec cap qa$1 deploy branch=$current_branch"
  else
            echo "Deploying $2"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                             bundle exec cap qa$1 deploy branch=$2"
  fi
}

function force_dqa() {
  if [ -z "$1" ]; then
        echo "Please provide a staging environment number.";
        return;
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]] ; then
        exec >&2; echo "Invalid staging number.";
        return;
  fi

  if [ -z "$2" ]; then
            current_branch=$(git rev-parse --abbrev-ref HEAD)
            echo "Deploying $current_branch"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                             bundle exec cap qa$1 deploy branch=$current_branch"
  else
            echo "Deploying $2"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                             bundle exec cap qa$1 deploy branch=$2"
  fi
}

function mdqa() {
  if [ -z "$1" ]; then
        echo "Please provide a QA environment number.";
        return;
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]] ; then
        exec >&2; echo "Invalid QA number.";
        return;
  fi

  remote_revision=$(ssh notonthehighstreet@qa$1.hq.noths.com 'cat /var/sites/notonthehighstreet/current/REVISION')
  current_revision=$(git log -1 --pretty=format:'%H')
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [ "$remote_revision" == "$current_revision" ]; then
        echo "Latest build already deployed."
  elif [ -z "$2" ]; then
            current_branch=$(git rev-parse --abbrev-ref HEAD)
            echo "Migrating and deploying $current_branch"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                           bundle exec cap qa$1 deploy branch=$current_branch migrate=yes"
  else
            echo "Migrating and deploying $2"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                           bundle exec cap qa$1 deploy branch=$2 migrate=yes"
  fi
}


function force_mdqa() {
  if [ -z "$1" ]; then
        echo "Please provide a QA environment number.";
        return;
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]] ; then
        exec >&2; echo "Invalid QA number.";
        return;
  fi

  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$2" ]; then
            current_branch=$(git rev-parse --abbrev-ref HEAD)
            echo "Migrating and deploying $current_branch"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                           bundle exec cap qa$1 deploy branch=$current_branch migrate=yes"
  else
            echo "Migrating and deploying $2"!

            run_cmd ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current &&
                           bundle exec cap qa$1 deploy branch=$2 migrate=yes"
  fi
}


function qa() {
  ssh notonthehighstreet@qa$*.hq.noths.com
}

function zeus_restart() {
  ssh vagrant@dev.noths.com "pgrep zeus | xargs kill -2" 2>/dev/null
  processes=`ssh vagrant@dev.noths.com "ps -ef | grep zeus | grep -v grep"`
  if [[ $processes != "" ]]
  then
    echo "Something went wrong, killing everything zeus-related"
    ssh vagrant@dev.noths.com "ps -ef | grep zeus | grep -v grep | awk '{print \$2}' | xargs kill -9"
    if [ -e /Users/AlexS/sites/noths/www/.zeus.sock ]
    then
      echo "Removing .zeus.sock"
      rm /Users/AlexS/sites/noths/www/.zeus.sock
    fi
  fi

  ssh vagrant@dev.noths.com "cd /var/sites/notonthehighstreet/current && zeus start" > /dev/null 2>&1 &
}

export JENKINS_USERNAME="JENKINS_USERNAME"
export JENKINS_PASSWORD="JENKINS_PASSWORD"

