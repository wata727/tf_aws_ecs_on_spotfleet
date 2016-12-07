require 'thor'
require 'aws-sdk'

class Wizard < Thor
  include Thor::Actions

  desc 'wizard generate', 'generate template for quick start'
  def generate
    ec2 = Aws::EC2::Resource.new(client: Aws::EC2::Client.new(region: 'us-east-1'))

    default_vpc_id = ec2.vpcs(filters: [{ name: 'isDefault', values: [true.to_s] }]).first.id
    subnet_ids = ec2.subnets(filters: [{ name: 'vpc-id', values: [default_vpc_id] }]).limit(2).map(&:id)
    key = ec2.key_pairs.first
    if key.nil?
      key = ec2.create_key_pair(key_name: 'demo-app')
      create_file 'demo-app.pem', key.key_material
    end

    template 'template.tf.erb', 'template.tf', { vpc_id: default_vpc_id, subnet_ids: subnet_ids, key_name: key.name }
  end

  desc 'wizard g', 'alias for wizard generate'
  alias_method :g, :generate
end

Wizard.source_root('.')
Wizard.start(ARGV)