import { Column, Entity, ManyToMany, PrimaryGeneratedColumn } from "typeorm";
import { User } from "../../user/entities/user.entity";

@Entity()
export class Record {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column()
  creator: number;

  @Column()
  from: Date;

  @Column()
  to: Date;

  @Column()
  description: string;

  @ManyToMany(type => User, user => user.records)
  users: User[];
}
