require 'project_manager'

class ServiceManager
  FailedToGetIP     = Class.new(StandardError)
  FailedToGetName   = Class.new(StandardError)
  IndexIsOutOfRange = Class.new(StandardError)
  IndexIsNotInteger = Class.new(StandardError)

  attr_reader :index, :name, :names, :service

  # @param  [String] service the name for Docker Compose
  def initialize(project, service, index=0)
    @project = project
    @service = service
    @names   = fetch_names
    send('index=', index)
  end

  # @param  [Integer] index
  def index=(index)
    raise IndexIsNotInteger unless index.kind_of?(Integer)
    raise IndexIsOutOfRange if index >= @names.length
    @index = index
    @name  = @names[index]
  end

  # Get an IP-Address of Docker container
  #
  # @param  [String] name of a container
  # @return [String] IP-Address
  def ip
    ip = %x!docker inspect \
             -f '{{.NetworkSettings.IPAddress}}' \
             #{@name}!.chomp

    raise FailedToGetIP if ip.length < 1
    ip
  end

  # Fetch container names from the service name
  def fetch_names
    names  = []
    result = project_manager.exec(
        "ps #{@service} | awk 'NR>2 {print $1}'")

    result.each_line do |line|
      line.chomp!
      names << line if line.length > 0
    end

    raise FailedToGetName if names.length < 1
    names
  end

  # Check a container existing
  #
  # @param  [String] name of a container
  # @return [Bool]
  def exist?
    system "docker inspect #{@name} > /dev/null 2>&1"
  end

  def project_manager
    ProjectManager.new(@project)
  end
end
