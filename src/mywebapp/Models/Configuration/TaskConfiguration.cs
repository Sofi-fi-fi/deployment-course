using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskEntity = mywebapp.Models.Entities.Task;

namespace mywebapp.Models.Configuration;

public class TaskConfiguration : IEntityTypeConfiguration<TaskEntity>
{
        public void Configure(EntityTypeBuilder<TaskEntity> builder)
        {
                builder.ToTable("tasks");

                builder.HasKey(t => t.Id);

                builder.Property(t => t.Title)
                        .IsRequired()
                        .HasMaxLength(200);

                builder.Property(t => t.Status)
                        .IsRequired()
                        .HasMaxLength(50);

                builder.Property(t => t.Created_At)
                        .IsRequired();
        }
}
