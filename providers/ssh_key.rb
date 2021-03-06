
def whyrun_supported?
  true
end

require 'chef/util/file_edit'

action :add do
  new_resource = @new_resource
  base_path = new_resource.base_path || node['git-ssh-server']['base_path']

  ssh_key_string = "#{new_resource.keytype} #{new_resource.key} #{new_resource.keyname}"
  ssh_key_regexp = Regexp.new('(?:^|\s)' + Regexp.escape(new_resource.keytype) + ' [ \t]*' + Regexp.escape(new_resource.key) + '(?:\s|$)')

  converge_by("Add #{new_resource.keyname}") do

    directory "#{base_path}/.ssh" do
      user node['git-ssh-server']['user']
      group node['git-ssh-server']['group']
      mode '00700'
    end

    file "#{base_path}/.ssh/authorized_keys" do
      content "# Generated by Chef"
      user node['git-ssh-server']['user']
      group node['git-ssh-server']['group']
      mode '00600'
      action :create_if_missing
    end

    ruby_block "filedit #{base_path}/.ssh/authorized_keys" do
      block do
        conf = Chef::Util::FileEdit.new("#{base_path}/.ssh/authorized_keys")
        conf.insert_line_if_no_match(ssh_key_regexp, ssh_key_string)
        conf.write_file
      end
    end

  end

end

