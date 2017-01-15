# audit_system_auth_password_strength
#
# Audit password strength
#.

audit_system_auth_password_strength () {
  auth_string=$1
  search_string=$2
  if [ "$os_name" = "Linux" ]; then
    if [ "$audit_mode" != 2 ]; then
      for check_file in /etc/pam.d/common-auth /etc/pam.d/system-auth; do
        if [ -f "$check_file" ]; then
          echo "Checking:  Password minimum strength enabled in $check_file"
          total=`expr $total + 1`
          check_value=`cat $check_file |grep '^$auth_string' |grep '$search_string$' |awk '{print $8}'`
          if [ "$check_value" != "$search_string" ]; then
            if [ "$audit_mode" = "1" ]; then
              insecure=`expr $insecure + 1`
              echo "Warning:   Password strength settings not enabled in $check_file [$insecure Warnings]"
              funct_verbose_message "" fix
              funct_verbose_message "" fix
              funct_verbose_message "" fix
            fi
            if [ "$audit_mode" = 0 ]; then
              funct_backup_file $check_file
              echo "Setting:   Password minimum length in $check_file"
              cp $check_file $temp_file
              cat $temp_file |sed 's/^password.*pam_deny.so$/&\npassword\t\trequisite\t\t\tpam_passwdqc.so min=disabled,disabled,16,12,8/' > $check_file
              rm $temp_file
            fi
          else
            if [ "$audit_mode" = "1" ]; then
              secure=`expr $secure + 1`
              echo "Secure:    Password strength settings enabled in $check_file [$secure Passes]"
            fi
          fi
        done
      fi
    else
      for check_file in /etc/pam.d/common-auth /etc/pam.d/system-auth; do
        funct_restore_file $check_file $restore_dir
      done
    fi
  fi
}
