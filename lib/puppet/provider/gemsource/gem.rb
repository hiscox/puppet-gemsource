require 'open3'
Puppet::Type.type(:gemsource).provide(:gem) do
  def gemexe
    if @resource[:pe] == :true
      '/opt/puppetlabs/puppet/bin/gem'
    else
      'gem'
    end
  end

  def configlocation
    if @resource[:globalconfig] == :true
      '--config-file /etc/gemrc'
    else
      ''
    end
  end

  def execgem(*args)
    if Open3.popen3("#{gemexe} #{configlocation} sources #{args.join(' ')}")[3].value.success? == false 
      raise Puppet::Error, "Error running #{gemexe} #{configlocation} #{args.join(' ')}"
    end
  end

  def exists?
    Open3.popen3("#{gemexe} #{configlocation} sources --list") do |stdin, stdout, stderr|
      stdout.each do |line|
        return true if line =~ /^#{resource[:url]}$/
      end
    end
  end

  def create
    execgem('--add', @resource[:url])
  end

  def destroy
    execgem('--remove', @resource[:url])
  end
end
